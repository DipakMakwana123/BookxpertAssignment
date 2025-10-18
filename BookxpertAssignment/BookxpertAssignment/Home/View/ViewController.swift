//
//  ViewController.swift
//  BookxpertAssignment
//
//  Created by Dipak Makwana on 17/10/25.
//

import UIKit

class ViewController: UIViewController {

    private var viewModel: NewsViewModel = .init()
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTable()
        Task {
            await viewModel.fetchNews()
            await MainActor.run { self.tableView.reloadData() }
        }
        // Do any additional setup after loading the view.
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
        } else {
            tableView.register(NewsTableCell.self, forCellReuseIdentifier: "NewsTableCell")
        }
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
