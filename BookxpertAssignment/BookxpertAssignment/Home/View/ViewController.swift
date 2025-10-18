//
//  ViewController.swift
//  BookxpertAssignment
//
//  Created by Dipak Makwana on 17/10/25.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    private let refreshControl = UIRefreshControl()
    private var viewModel: NewsViewModel = .init()
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTable()

        // Preload cached articles so UI shows immediately when offline
        if let cached = ArticleCache.load() {
            self.viewModel.articles = cached.articles ?? []
            self.tableView.reloadData()
        }

        // Then try to fetch fresh data
        loadData()
        // Do any additional setup after loading the view.
    }

    private func loadData() {
        Task {
            await viewModel.fetchNews()
            await MainActor.run {
                if self.viewModel.articles.isEmpty, let cached = ArticleCache.load() {
                    self.viewModel.articles = cached.articles ?? []
                }
                self.tableView.reloadData()
                if self.refreshControl.isRefreshing { self.refreshControl.endRefreshing() }
            }
        }
    }
    private func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100 
        // Register the cell. Adjust nib/name if using a nib or storyboard prototype cell.
        if let _ = Bundle.main.path(forResource: "NewsTableCell", ofType: "nib") {
            let nib = UINib(nibName: "NewsTableCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "NewsTableCell")
        }
        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
    @objc private func handleRefresh() {
        loadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.articles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableCell", for: indexPath) as? NewsTableCell ?? NewsTableCell(style: .default, reuseIdentifier: "NewsTableCell")
        // Configure the cell with the corresponding article if needed
        let article = viewModel.articles[indexPath.row]
        cell.configure(with: article)
        return cell
    }
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
