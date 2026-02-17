import UIKit

class MarketsListViewController: UIViewController, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.filterCoins(with: searchText)
    }
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let viewModel = MarketsListViewModel()
    private let refreshControl = UIRefreshControl()
    private let sortingHeader = SortingHeaderView()
    
    private let filterStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var periodButton: UIButton = {
        let button = UIButton(configuration: .capsuleFilter(title: "24h"))
        
        let actions = ["24h", "7d", "30d"].map { period in
            UIAction(title: period, state: period == "24h" ? .on : .off) { [weak self] _ in
                self?.viewModel.changePeriod(period)
                self?.sortingHeader.updateChangeTitle(to: period)
            }
        }
        
        button.menu = UIMenu(title: "Select Period", children: actions)
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        return button
    }()
    
    private lazy var rangeButton: UIButton = {
        let button = UIButton(configuration: .capsuleFilter(title: "Top 100"))
        
        let actions = [
            UIAction(title: "Top 100", state: .on) { [weak self] _ in self?.updateFilter(100) },
            UIAction(title: "Top 300") { [weak self] _ in self?.updateFilter(300) },
            UIAction(title: "Top 500") { [weak self] _ in self?.updateFilter(500) }
        ]
        
        button.menu = UIMenu(title: "Select Range", children: actions)
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchInNavBar()
        setupUI()
        setupBindings()
        setupHeaderActions()
        viewModel.fetchCoins()
    }
    
    private func setupSearchInNavBar() {
        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Coins..."
        searchController.obscuresBackgroundDuringPresentation = false
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 110))
        headerContainer.backgroundColor = .systemBackground
        
        let filterStack = UIStackView(arrangedSubviews: [rangeButton, periodButton])
        filterStack.axis = .horizontal
        filterStack.distribution = .equalSpacing
        filterStack.translatesAutoresizingMaskIntoConstraints = false
        
        headerContainer.addSubview(filterStack)
        headerContainer.addSubview(sortingHeader)
        sortingHeader.translatesAutoresizingMaskIntoConstraints = false
        
        let filterHeight = filterStack.heightAnchor.constraint(equalToConstant: 40)
        filterHeight.priority = .init(999)
        
        let sortingHeight = sortingHeader.heightAnchor.constraint(equalToConstant: 40)
        sortingHeight.priority = .init(999)
        
        let filterTrailing = filterStack.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16)
        filterTrailing.priority = .init(999)
        
        let sortingTrailing = sortingHeader.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor)
        sortingTrailing.priority = .init(999)
        
        NSLayoutConstraint.activate([
            filterStack.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 10),
            filterStack.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            filterTrailing,
            filterHeight,
            
            sortingHeader.topAnchor.constraint(equalTo: filterStack.bottomAnchor, constant: 10),
            sortingHeader.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            sortingTrailing,
            sortingHeader.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            sortingHeight
        ])
        
        headerContainer.setNeedsLayout()
        headerContainer.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: UIView.layoutFittingCompressedSize.height)
        let size = headerContainer.systemLayoutSizeFitting(targetSize,
                                                           withHorizontalFittingPriority: .required,
                                                           verticalFittingPriority: .fittingSizeLevel)
        headerContainer.frame.size.height = size.height
        
        tableView.tableHeaderView = headerContainer
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CoinCell.self, forCellReuseIdentifier: CoinCell.identifier)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupHeaderActions() {
        sortingHeader.onSortPrice = { [weak self] in
            guard let self = self else { return }
            self.viewModel.sortData(by: .price)
            self.sortingHeader.updateChevrons(selectedType: .price, isAscending: self.viewModel.getAscending())
        }
        
        sortingHeader.onSortMarketCap = { [weak self] in
            guard let self = self else { return }
            self.viewModel.sortData(by: .marketCap)
            self.sortingHeader.updateChevrons(selectedType: .marketCap, isAscending: self.viewModel.getAscending())
        }
        
        sortingHeader.onSortChange = { [weak self] in
            guard let self = self else { return }
            self.viewModel.sortData(by: .change)
            self.sortingHeader.updateChevrons(selectedType: .change, isAscending: self.viewModel.getAscending())
        }
    }
    
    private func updateFilter(_ limit: Int) {
        rangeButton.setTitle("Top \(limit)", for: .normal)
        viewModel.fetchCoins(limit: limit)
    }
    
    private func setupBindings() {
        viewModel.onDataUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.tableView.alpha = 1.0
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc private func refreshData() {
        viewModel.fetchCoins(forceRefresh: true)
    }
}

// MARK: - UITableView Extensions
extension MarketsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isSearchActive ? viewModel.filteredCoins.count : viewModel.coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CoinCell.identifier, for: indexPath) as! CoinCell
        
        let coin = viewModel.isSearchActive ? viewModel.filteredCoins[indexPath.row] : viewModel.coins[indexPath.row]
        
        cell.configure(with: coin, period: viewModel.currentPeriod)
        return cell
    }
}

extension MarketsListViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let coin = viewModel.coins[indexPath.row]
        
        let detailVC = CoinDetailViewController(coin: coin)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension UIButton.Configuration {
    static func capsuleFilter(title: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.tinted()
        config.title = title
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        config.baseForegroundColor = .label
        config.baseBackgroundColor = .systemGray3
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .rounded(ofSize: 16, weight: .semibold)
            return outgoing
        }
        return config
    }
}
