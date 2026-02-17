import Foundation
import UIKit

enum SortType {
    case marketCap, change, price
}

class MarketsListViewModel {
    // MARK: - Properties
    private(set) var coins: [Coin] = []
    private(set) var filteredCoins: [Coin] = []
    private(set) var currentPeriod: String = "24h"
    private var isAscending = false
    private var currentLimit: Int = 100
    
    var isSearchActive: Bool = false
    
    // Keys and cache settings
    private let lastUpdateKey = "lastCoinUpdate"
    private let cachedCoinsKey = "cachedCoins"
    private var lastFetchDate: Date?
    private let cacheInterval: TimeInterval = 300 // 5 min
    
    var onDataUpdate: (() -> Void)?
    
    // MARK: - Init
    init() {
        if let lastUpdate = UserDefaults.standard.object(forKey: lastUpdateKey) as? Date {
            self.lastFetchDate = lastUpdate
        }
    }
    
    // MARK: - Public Methods
    
    func filterCoins(with query: String) {
        if query.isEmpty {
            isSearchActive = false
            filteredCoins = []
        } else {
            isSearchActive = true
            filteredCoins = coins.filter { coin in
                coin.name.lowercased().contains(query.lowercased()) ||
                coin.symbol.lowercased().contains(query.lowercased())
            }
        }
        onDataUpdate?()
    }
    
    func getAscending() -> Bool {
        return isAscending
    }
    
    func changePeriod(_ period: String) {
        self.currentPeriod = period
        onDataUpdate?()
    }
    
    func sortData(by type: SortType) {
        isAscending.toggle()
        
        switch type {
        case .price:
            coins.sort { isAscending ? $0.currentPrice < $1.currentPrice : $0.currentPrice > $1.currentPrice }
        case .marketCap:
            coins.sort { a, b in
                let rankA = a.marketCapRank ?? 999999
                let rankB = b.marketCapRank ?? 999999
                return isAscending ? rankA > rankB : rankA < rankB
            }
        case .change:
            coins.sort { a, b in
                let valA = getChangeValue(for: a) ?? -Double.greatestFiniteMagnitude
                let valB = getChangeValue(for: b) ?? -Double.greatestFiniteMagnitude
                return isAscending ? valA < valB : valA > valB
            }
        }
        
        self.onDataUpdate?()
    }

    func fetchCoins(limit: Int? = nil, forceRefresh: Bool = false) {
        if let limit = limit { self.currentLimit = limit }
        
        if !forceRefresh,
           let lastFetch = lastFetchDate,
           Date().timeIntervalSince(lastFetch) < cacheInterval,
           self.coins.count >= currentLimit {
            
            print("Using cache, protect API limits")
            self.onDataUpdate?()
            return
        }
        
        Task {
            do {
                var allFetchedCoins: [Coin] = []
                
                if currentLimit <= 250 {
                    allFetchedCoins = try await NetworkManager.shared.fetchCoins(perPage: currentLimit, page: 1)
                } else {
                    let page1 = try await NetworkManager.shared.fetchCoins(perPage: 250, page: 1)
                    // Pause 0.5 seconds between requests so that CoinGecko does not swear
                    try await Task.sleep(nanoseconds: 500_000_000)
                    let page2 = try await NetworkManager.shared.fetchCoins(perPage: currentLimit - 250, page: 2)
                    
                    allFetchedCoins = page1 + page2
                }
                
                self.coins = allFetchedCoins
                let now = Date()
                self.lastFetchDate = now
                
                if let encoded = try? JSONEncoder().encode(allFetchedCoins) {
                    UserDefaults.standard.set(encoded, forKey: cachedCoinsKey)
                    UserDefaults.standard.set(now, forKey: lastUpdateKey)
                }

                await MainActor.run {
                    self.onDataUpdate?()
                }
            } catch {
                print("Ошибка загрузки: \(error.localizedDescription)")
                // If there is an error (for example, 429), but there are old coins in memory, simply update the UI with them
                if !self.coins.isEmpty {
                    await MainActor.run { self.onDataUpdate?() }
                }
            }
        }
    }
    
    func fetchCoinsIfNeeded() {
        if let cachedData = UserDefaults.standard.data(forKey: cachedCoinsKey),
           let decodedCoins = try? JSONDecoder().decode([Coin].self, from: cachedData),
           let lastUpdate = UserDefaults.standard.object(forKey: lastUpdateKey) as? Date {
            
            if Date().timeIntervalSince(lastUpdate) < cacheInterval {
                self.coins = decodedCoins
                self.lastFetchDate = lastUpdate
                self.onDataUpdate?()
                print("Took data from the cache so as not to waste the limit")
                return
            }
        }
        
        fetchCoins()
    }
    
    // MARK: - Helpers
    private func getChangeValue(for coin: Coin) -> Double? {
        switch currentPeriod {
        case "7d": return coin.priceChangePercentage7D
        case "30d": return coin.priceChangePercentage30D
        default: return coin.priceChangePercentage24H
        }
    }
}
