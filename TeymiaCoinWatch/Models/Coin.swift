import Foundation

struct Coin: Codable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double
    let marketCapRank: Int?
    
    let priceChangePercentage24H: Double?
    let priceChangePercentage7D: Double?
    let priceChangePercentage30D: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case priceChangePercentage24H = "price_change_percentage_24h_in_currency"
        case priceChangePercentage7D = "price_change_percentage_7d_in_currency"
        case priceChangePercentage30D = "price_change_percentage_30d_in_currency"
    }
}
