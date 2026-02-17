import UIKit

class SortingHeaderView: UIView {
    
    var onSortMarketCap: (() -> Void)?
    var onSortChange: (() -> Void)?
    var onSortPrice: (() -> Void)?
    
    private let marketCapButton = UIButton.createSortButton(title: "Market Cap")
    private let changeButton = UIButton.createSortButton(title: "24h%")
    private let priceButton = UIButton.createSortButton(title: "Price")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        let stack = UIStackView(arrangedSubviews: [marketCapButton, changeButton, priceButton])
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        changeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        priceButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        marketCapButton.contentHorizontalAlignment = .left
        changeButton.contentHorizontalAlignment = .right
        priceButton.contentHorizontalAlignment = .right
        
        let changeWidth = changeButton.widthAnchor.constraint(equalToConstant: 70)
        changeWidth.priority = .init(999)

        let priceWidth = priceButton.widthAnchor.constraint(equalToConstant: 110)
        priceWidth.priority = .init(999)

        let stackTrailing = stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        stackTrailing.priority = .init(999)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 55),
            stackTrailing,
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            changeWidth,
            priceWidth
        ])

        marketCapButton.contentHorizontalAlignment = .left
        
        marketCapButton.addTarget(self, action: #selector(capTapped), for: .touchUpInside)
                changeButton.addTarget(self, action: #selector(changeTapped), for: .touchUpInside)
                priceButton.addTarget(self, action: #selector(priceTapped), for: .touchUpInside)
    }
    
    @objc private func capTapped() { onSortMarketCap?() }
    @objc private func changeTapped() { onSortChange?() }
    @objc private func priceTapped() { onSortPrice?() }
    
    func updateChevrons(selectedType: SortType, isAscending: Bool) {
        let buttons = [marketCapButton, changeButton, priceButton]
        let types: [SortType] = [.marketCap, .change, .price]
        let assetName = isAscending ? "caret.up" : "caret.down"
        
        let iconSize = CGSize(width: 14, height: 14)
        
        for (index, button) in buttons.enumerated() {
            let isSelected = types[index] == selectedType
            let currentAssetName = isSelected ? assetName : "caret.down"
            
            var newConfig = button.configuration
            
            let image = UIImage(named: currentAssetName)?.resized(to: iconSize)
            newConfig?.image = image?.withRenderingMode(.alwaysTemplate)
            
            button.configuration = newConfig
            button.tintColor = isSelected ? .label : .secondaryLabel
        }
    }
    
    func updateChangeTitle(to period: String) {
        var config = changeButton.configuration
        config?.title = "\(period)%"
        changeButton.configuration = config
    }
}

extension UIButton {
    static func createSortButton(title: String) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let resizedImage = UIImage(named: "caret.down")?.resized(to: CGSize(width: 14, height: 14))
        config.image = resizedImage?.withRenderingMode(.alwaysTemplate)
        
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.baseForegroundColor = .secondaryLabel
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .rounded(ofSize: 12, weight: .medium)
            return outgoing
        }
        
        let btn = UIButton(configuration: config)
        btn.contentHorizontalAlignment = .right
        
        return btn
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
