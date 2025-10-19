//
//  ViewController.swift
//  BookxpertAssignment
//
//  Created by Dipak Makwana on 17/10/25.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    override var title: String? {
        didSet {
            // Keep tab title in sync when set externally
            self.tabBarItem.title = title
        }
    }
    private let refreshControl = UIRefreshControl()
    private var viewModel: NewsViewModel
    fileprivate let searchController = UISearchController(
        searchResultsController: nil
    )

    @IBOutlet weak var tableView: UITableView?

    private func showError(_ message: String) {
        // Avoid presenting multiple alerts at once
        if self.presentedViewController is UIAlertController { return }
        let alert = UIAlertController(title: "Something went wrong", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            self?.loadData()
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

    // Designated initializer when creating programmatically
    init(viewModel: NewsViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    // Required initializer for storyboard/XIB support
    required init?(coder: NSCoder) {
        self.viewModel = NewsViewModel()
        super.init(coder: coder)
    }

    // Convenience initializer to match default init pattern (optional)
    convenience override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.init(viewModel: .init())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "News"
        configureTabItem()
        configureTable()
        configureSearch()
        // Preload cached articles so UI shows immediately when offline
        if let articles = ArticleCache.load() {
            self.viewModel.articles = articles
            self.reloadData()
        }
        // Then try to fetch fresh data
        loadData()
        // Do any additional setup after loading the view.
    }

    private func configureTabItem() {
        if self.tabBarItem.image == nil {
            self.tabBarItem = UITabBarItem(title: "News", image: UIImage(systemName: "newspaper"), selectedImage: UIImage(systemName: "newspaper.fill"))
        }
    }
    private func reloadData() {
        Task {
            await MainActor.run { [weak  self] in
                self?.tableView?.reloadData()
            }
        }
    }

    private func loadData() {
        Task {
            await viewModel.fetchNews()
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.reloadData()
                if !(self.searchController.isActive && !(self.searchController.searchBar.text ?? "").isEmpty) {
                    self.viewModel.filteredArticles = self.viewModel.articles
                }
                if self.refreshControl.isRefreshing { self.refreshControl.endRefreshing() }

                if let error = self.viewModel.errorMessage, !error.isEmpty {
                    self.showError(error)
                    // Clear after showing to prevent duplicate alerts
                    self.viewModel.errorMessage = nil
                }
            }
        }
    }
    private func configureTable() {
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 100
        // Register the cell. Adjust nib/name if using a nib or storyboard prototype cell.
        if let _ = Bundle.main.path(forResource: "NewsTableCell", ofType: "nib") {
            let nib = UINib(nibName: "NewsTableCell", bundle: nil)
            tableView?.register(nib, forCellReuseIdentifier: "NewsTableCell")
        }
        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView?.refreshControl = refreshControl
        } else {
            tableView?.addSubview(refreshControl)
        }
    }

    private func configureSearch() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search articles"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    @objc private func handleRefresh() {
        loadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  source.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableCell", for: indexPath) as? NewsTableCell ?? NewsTableCell(style: .default, reuseIdentifier: "NewsTableCell")
        let article = source[indexPath.row]
        cell.configure(with: article)
        if let button = cell.btnBookmark {
            button.tag = indexPath.row
            button.removeTarget(nil, action: nil, for: .allEvents)
            button.addTarget(self, action: #selector(btnBookmarkTapped(_:)), for: .touchUpInside)
        }
        return cell
    }

    // TODO: We can move this below code to view model, but due to API_Key Usage limitation , i am uanble to check but i added code in ViewModel  func updateBookmark which is not tested , so i have not implemented here
    private var source: [Article] {
        let isSearching = searchController.isActive && !(searchController.searchBar.text ?? "").isEmpty
        return isSearching ? viewModel.filteredArticles : viewModel.articles
    }
    @objc func btnBookmarkTapped(_ sender: UIButton) {
        let index = sender.tag
        // Determine current data source (filtered vs full)
        let isSearching = searchController.isActive && !(searchController.searchBar.text ?? "").isEmpty
        let currentSource = isSearching ? viewModel.filteredArticles : viewModel.articles
        guard currentSource.indices.contains(index) else { return }
        var article = currentSource[index]
        article.isBookmarked = article.isBookmarked == nil ? true : !(article.isBookmarked ?? false)
        // Update backing arrays: first update in viewModel.articles
        if let fullIndex = viewModel.articles.firstIndex(where: { ($0.url ?? $0.title) == (article.url ?? article.title) }) {
            viewModel.articles[fullIndex] = article
        }
        // If searching, also update filtered array element to keep UI consistent
        if isSearching {
            viewModel.filteredArticles[index] = article
        }
        ArticleCache
            .updateBookmark(
                id: article.id,
                isBookmarked:  article.isBookmarked ?? false
            )
        // Reload just the affected row for a smooth UI update
        let indexPath = IndexPath(row: index, section: 0)
        tableView?.reloadRows(at: [indexPath], with: .automatic)
    }
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ViewController: UISearchResultsUpdating {
    // TODO: We can move this below code to view model, but due to API_Key Usage limitation , i am uanble to check further but i added code in ViewModel  func filterNews which is not tested , so i have not implemented here
    func updateSearchResults(for searchController: UISearchController) {
        let query = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        //viewModel.filterNews(query)
        guard !query.isEmpty else {
            viewModel.filteredArticles = viewModel.articles
            reloadData()
            return
        }
        let lower = query.lowercased()
        viewModel.filteredArticles = viewModel.articles.filter { article in
            let title = article.title?.lowercased() ?? ""
            let author = article.author?.lowercased() ?? ""
            return title.contains(lower) || author.contains(lower)
        }
        self.reloadData()
    }
}

