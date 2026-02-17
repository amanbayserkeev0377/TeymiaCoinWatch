import Foundation

extension Double {
    func asCurrencyWithAbbreviation() -> String {
        let num = abs(Double(self))
        let sign = (self < 0) ? "-" : ""
        
        switch num {
        case 1_000_000_000_000...:
            return "\(sign)$" + String(format: "%.2fT", num / 1_000_000_000_000)
        case 1_000_000_000...:
            return "\(sign)$" + String(format: "%.2fB", num / 1_000_000_000)
        case 1_000_000...:
            return "\(sign)$" + String(format: "%.2fM", num / 1_000_000)
        default:
            return "\(sign)$" + String(format: "%.2f", num)
        }
    }
}
