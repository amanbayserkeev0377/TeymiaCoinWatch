import UIKit

class CoinDetailViewController: UIViewController {
    
    var coin: Coin?
    
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    
    init(coin: Coin) {
        self.coin = coin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureData()
    }
    
    private func setupUI() {
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        priceLabel.font = .systemFont(ofSize: 20, weight: .medium)
        priceLabel.textColor = .systemGreen
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func configureData() {
        guard let coin else { return }
        title = coin.symbol.uppercased()
        nameLabel.text = coin.name
        priceLabel.text = "$\(coin.currentPrice)"
        
        ImageLoader.shared.downloadImage(from: coin.image) { [weak self] image in
            self?.imageView.image = image
        }
    }
}
