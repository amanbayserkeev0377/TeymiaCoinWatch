import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetchCoins(perPage: Int = 100, page: Int = 1) async throws -> [Coin] {
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=\(perPage)&page=\(page)&sparkline=false&price_change_percentage=24h,7d,30d"
        
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 429 {
            print("Request limit has been reached.")
            throw NSError(domain: "CoinAPI", code: 429, userInfo: [NSLocalizedDescriptionKey: "Too many requests. Please wait."])
        }
        
        do {
            return try JSONDecoder().decode([Coin].self, from: data)
        } catch {
            print("Ошибка декодирования: \(error)")
            throw error
        }
    }
}
