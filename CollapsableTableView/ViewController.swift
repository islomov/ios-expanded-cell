//
//  ViewController.swift
//  CollapsableTableView
//
//  Created by Sardor Islomov on 10/19/20.
//

import UIKit
import Foundation

class ViewController: UITableViewController {
    
    private let apiKey = "39e387e9c56948158d79a78ec3da7793"
    private let cellIdentifier = "myCell"
    
    var models: [NewsViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.beginRefreshing()
        loadNews()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        tableView.refreshControl?.beginRefreshing()
        loadNews()
    }
    
    private func loadNews() {
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd"
        let dateString = formatter.string(from: Date())

        guard let url = URL(string: "https://newsapi.org/v2/everything?q=apple&language=en&from=\(dateString)&sortBy=publishedAt&apiKey=\(apiKey)") else {
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                let jsonDecoder = JSONDecoder()
                guard let data = data, let newsResult = try? jsonDecoder.decode(NewsResult.self, from: data) else {
                    return
                }
                self.models.removeAll()
                self.models = newsResult.articles.map({ NewsViewModel(article: $0) })
                self.tableView.reloadData()
            }
        }.resume()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        let model = models[indexPath.row]
        cell.textLabel?.text = model.article.title
        cell.detailTextLabel?.text = model.body
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = models[indexPath.row]
        var indexPaths = [indexPath]
        
        if let expandedIndex = models.firstIndex(where: { $0.state == .expanded }) {
            let expandedItem = models[expandedIndex]
            expandedItem.state = .fixed
            if expandedIndex == indexPath.row {
                tableView.reloadRows(at: indexPaths, with: .automatic)
                return
            }
            indexPaths.append(IndexPath(row: expandedIndex, section: 0))
        }
        
        model.state = .expanded
        tableView.reloadRows(at: indexPaths, with: .fade)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }


}
