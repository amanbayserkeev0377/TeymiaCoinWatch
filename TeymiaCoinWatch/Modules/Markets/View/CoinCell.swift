import UIKit

class CoinCell: UITableViewCell {
    static let identifier = "CoinCell"
    
    private let rankLabel = UILabel()
    private let coinImageView = UIImageView()
    private let nameLabel = UILabel()
    private let marketCapLabel = UILabel()
    private let changeLabel = UILabel()
    private let priceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coinImageView.image = nil
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        rankLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        rankLabel.textColor = .secondaryLabel
        rankLabel.textAlignment = .left
        rankLabel.minimumScaleFactor = 0.8
        
        nameLabel.font = .rounded(ofSize: 16, weight: .medium)
        marketCapLabel.font = .rounded(ofSize: 14, weight: .regular)
        marketCapLabel.textColor = .secondaryLabel
        
        coinImageView.contentMode = .scaleAspectFill
        coinImageView.layer.cornerRadius = 12
        coinImageView.clipsToBounds = true
        coinImageView.backgroundColor = .clear
        
        changeLabel.font = .rounded(ofSize: 16, weight: .medium)
        changeLabel.adjustsFontSizeToFitWidth = true
        changeLabel.minimumScaleFactor = 0.8
        
        priceLabel.font = .rounded(ofSize: 18, weight: .medium)
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.minimumScaleFactor = 0.8
        
        let nameStack = UIStackView(arrangedSubviews: [nameLabel, marketCapLabel])
        nameStack.axis = .vertical
        nameStack.alignment = .leading
        nameStack.spacing = 4
        
        let mainStack = UIStackView(arrangedSubviews: [rankLabel, coinImageView, nameStack, changeLabel, priceLabel])
        mainStack.axis = .horizontal
        mainStack.spacing = 8
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStack)
        
        changeLabel.textAlignment = .right
        priceLabel.textAlignment = .right
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            rankLabel.widthAnchor.constraint(equalToConstant: 28),
            coinImageView.widthAnchor.constraint(equalToConstant: 24),
            coinImageView.heightAnchor.constraint(equalToConstant: 24),
            
            changeLabel.widthAnchor.constraint(equalToConstant: 70),
            priceLabel.widthAnchor.constraint(equalToConstant: 110)
        ])
    }
    
    func configure(with coin: Coin, period: String) {
        if let rank = coin.marketCapRank {
            rankLabel.text = "\(rank)"
        } else {
            rankLabel.text = "-"
        }
        nameLabel.text = coin.symbol.uppercased()
        priceLabel.text = String(format: "$%.2f", coin.currentPrice)
        marketCapLabel.text = coin.marketCap.asCurrencyWithAbbreviation()
        
        let changeValue: Double?
        switch period {
        case "7d": changeValue = coin.priceChangePercentage7D
        case "30d": changeValue = coin.priceChangePercentage30D
        default: changeValue = coin.priceChangePercentage24H
        }
        
        if let change = changeValue {
            let isPositive = change >= 0
            changeLabel.text = String(format: "%.2f%%", change)
            changeLabel.textColor = isPositive ? UIColor(named: "appGreenColor") : UIColor(named: "appRedColor")
        } else {
            changeLabel.text = "---"
            changeLabel.textColor = .secondaryLabel
        }
        
        coinImageView.image = nil
        coinImageView.backgroundColor = .clear
        coinImageView.startShimmering()
        
        ImageLoader.shared.downloadImage(from: coin.image) { [weak self] image in
            DispatchQueue.main.async {
                self?.coinImageView.stopShimmering()
                self?.coinImageView.image = image
            }
        }
    }
}
