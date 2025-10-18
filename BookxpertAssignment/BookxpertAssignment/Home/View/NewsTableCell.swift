//
//  NewsTableCell.swift
//  BookxpertAssignment
//
//  Created by Dipak Makwana on 17/10/25.
//

import UIKit
import SDWebImage



class NewsTableCell: UITableViewCell {
    static let reuseIdentifier = "NewsTableViewCell"

    @IBOutlet weak var titleLable: UILabel?
    @IBOutlet weak var subtitleLable: UILabel?
    @IBOutlet weak var btnBookmark: UIButton?
    @IBOutlet weak var thumbImageView: SDAnimatedImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureView()
    }

    private func configureView() {
        titleLable?.numberOfLines = 2
        subtitleLable?.numberOfLines = 1
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    /// Reuse identifier for the cell.
    /// Configures the cell with an article.
    /// - Parameter article: The article to display.
    func configure(with article: Article) {
        titleLable?.text = article.title ?? "No Title"
        subtitleLable?.text = article.author ?? "No Author"

        let placeholder = UIImage(named: "placeholder.png")
        let urlString = article.urlToImage ?? ""
        let url = URL(string: urlString)
        let isBookmarked = article.isBookmarked ?? false
        let image = UIImage(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
        btnBookmark?.setImage(image, for: .normal)
        // Workaround for buggy ImageIO PNG decoder on indexed-color PNGs:
        // Prefer SDWebImage's PNG coder via context and use safe decoding options.
        thumbImageView?.sd_setImage(with: url, placeholderImage: placeholder)
    }
}
