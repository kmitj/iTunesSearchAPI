//
//  ViewController.swift
//  iTunesSearchApi
//
//  Created by km1tj on 22/08/24.
//

import UIKit

final class SearchViewController: UIViewController {
    
    let searchViewController = UISearchController(searchResultsController: nil)
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    let viewModel: SearchViewModel
    
    let historyTableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    let resultLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        view.textColor = UIColor.darkGray
        view.numberOfLines = 0
        view.textAlignment = .center
        view.lineBreakMode = .byWordWrapping
        view.text = "Enter name to start searching"
        return view
    }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(SearchItemCell.self, forCellWithReuseIdentifier: "cell")
        view.backgroundColor = .white
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()
    lazy var layout: UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
            guard let self = self else { return nil }
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0/3.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: groupSize.heightDimension), subitems: [item])
            group.interItemSpacing = .fixed(10)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10
            section.contentInsets = .init(top: 10, leading: 10, bottom: 20, trailing: 10)
            return section
        }
    }()
    lazy var listDataSource: UICollectionViewDiffableDataSource<Int, SearchEntity> = {
        return UICollectionViewDiffableDataSource<Int, SearchEntity>(collectionView: self.collectionView) { [weak self]
            (collectionView: UICollectionView, indexPath: IndexPath, item: SearchEntity) -> UICollectionViewCell? in
            guard let self = self else { return UICollectionViewCell() }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SearchItemCell else {
                return UICollectionViewCell()
            }
            cell.configure(data: item)
            return cell
        }
    }()
    

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.searchController = self.searchViewController
        self.navigationItem.title = "iTunesSearchAPI"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Limit", style: .plain, target: self, action: #selector(self.selectLimit))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Kind", style: .plain, target: self, action: #selector(self.selectMediaType))
        self.view.addSubview(self.resultLabel)
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.historyTableView)
        self.view.addSubview(self.loadingIndicator)
        self.collectionView.dataSource = self.listDataSource
        self.collectionView.delegate = self
        self.loadingIndicator.hidesWhenStopped = true
        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.searchViewController.searchBar.delegate = self
        self.searchViewController.hidesNavigationBarDuringPresentation = false
        self.historyTableView.translatesAutoresizingMaskIntoConstraints = false
        self.historyTableView.dataSource = self
        self.historyTableView.delegate = self
        self.historyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "historyCell")
        NSLayoutConstraint.activate([
            self.historyTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.historyTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.historyTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.historyTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.resultLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.resultLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            self.resultLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
        ])
        self.viewModel.stateChanged = { [weak self] state in
            DispatchQueue.main.async {
                self?.updateUI(state: state)
            }
        }
        self.updateUI(state: .empty)
    }
    
    @objc func selectLimit() {
        let alertAction = UIAlertController(title: "Limit", message: nil, preferredStyle:.actionSheet)
        alertAction.addAction(.init(title: "20", style: self.viewModel.limit == 20 ? .destructive : .default, handler: { _ in
            self.viewModel.limit = 20
        }))
        alertAction.addAction(.init(title: "50", style: self.viewModel.limit == 50 ? .destructive : .default, handler: { _ in
            self.viewModel.limit = 50
        }))
        alertAction.addAction(.init(title: "100", style: self.viewModel.limit == 100 ? .destructive : .default, handler: { _ in
            self.viewModel.limit = 100
        }))
        alertAction.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in }))
        self.present(alertAction, animated: true)
    }
    
    @objc func selectMediaType() {
        let alertAction = UIAlertController(title: "Select kind", message: nil, preferredStyle:.actionSheet)
        for i in SearchMediaType.allCases {
            alertAction.addAction(.init(title: i.rawValue.capitalized, style: self.viewModel.kind == i ? .destructive : .default, handler: { _ in
                self.viewModel.kind = i
            }))
        }
        alertAction.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in }))
        self.present(alertAction, animated: true)
    }
    
    func updateUI(state: ViewState) {
        switch state {
        case .empty:
            self.viewModel.filteredHistory = self.viewModel.searchHistory
            self.collectionView.isHidden = true
            self.historyTableView.isHidden = true
            self.resultLabel.isHidden  = false
            self.resultLabel.text = "Enter name to start searching"
        case .loading:
            self.collectionView.isHidden = true
            self.historyTableView.isHidden = true
            self.resultLabel.isHidden  = true
            self.loadingIndicator.startAnimating()
        case .success:
            self.historyTableView.isHidden = true
            self.loadingIndicator.stopAnimating()
            var snapshot = NSDiffableDataSourceSnapshot<Int, SearchEntity>()
            snapshot.appendSections([0])
            snapshot.appendItems(self.viewModel.searchItems, toSection: 0)
            self.listDataSource.apply(snapshot, animatingDifferences: true)
            if self.viewModel.searchItems.isEmpty {
                self.collectionView.isHidden = true
                self.resultLabel.isHidden  = false
                self.resultLabel.text = "Results is empty. Try another name"
            } else {
                self.collectionView.isHidden = false
                self.resultLabel.isHidden  = true
            }
        case .error(let string):
            self.loadingIndicator.stopAnimating()
            self.resultLabel.isHidden  = false
            self.resultLabel.text = string
        }
    }
    
    func resetDataSet() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SearchEntity>()
        snapshot.appendSections([0])
        snapshot.appendItems([], toSection: 0)
        self.listDataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        self.viewModel.updateSearchHistory(query: query)
        searchBar.resignFirstResponder()
        self.viewModel.filteredHistory = self.viewModel.searchHistory
        self.historyTableView.reloadData()
        self.viewModel.performSearch(query: query)
   }
   
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.resetDataSet()
        self.updateUI(state: .empty)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.viewModel.filteredHistory = self.viewModel.searchHistory
        } else {
            self.viewModel.filteredHistory = self.viewModel.searchHistory.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        self.historyTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.historyTableView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.historyTableView.isHidden = true
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.viewModel.searchItems[indexPath.item]
        self.navigationController?.pushViewController(DetailViewController(viewModel: .init(networkService: self.viewModel.networkService, entity: item)), animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.filteredHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        cell.textLabel?.text = self.viewModel.filteredHistory[indexPath.row]
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedQuery = self.viewModel.filteredHistory[indexPath.row]
        self.searchViewController.searchBar.text = selectedQuery
        self.searchBarSearchButtonClicked(self.searchViewController.searchBar)
    }
}
