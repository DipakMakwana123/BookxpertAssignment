import UIKit

final class BookmarkViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)

    private var viewModel: BookmarkViewModel

    init(viewModel: BookmarkViewModel ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = BookmarkViewModel()
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    



    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bookmark"
        view.backgroundColor = .systemBackground
        setupTable()
        loadBookmarks()
    }

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
        if let _ = Bundle.main.path(forResource: "NewsTableCell", ofType: "nib") {
            let nib = UINib(nibName: "NewsTableCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "NewsTableCell")
        }
    }

    private func loadBookmarks() {
        tableView.reloadData()
    }
}

extension BookmarkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookmarked.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableCell", for: indexPath) as? NewsTableCell ?? NewsTableCell(style: .default, reuseIdentifier: "NewsTableCell")
        let article = viewModel.bookmarked[indexPath.row]
        cell.configure(with: article)
        return cell
    }
}

extension BookmarkViewController: UITableViewDelegate {}

