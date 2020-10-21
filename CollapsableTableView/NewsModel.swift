//
//  NewsModel.swift
//  CollapsableTableView
//
//  Created by Sardor Islomov on 10/19/20.
//

import Foundation

class NewsViewModel {

    enum State {
        case fixed
        case expanded
    }

    let article: Article
    var state: State
    
    var body: String {
        state == .expanded ? (article.description + "\n" + article.content) : article.description
    }
    
    init(article: Article, state: State = .fixed) {
        self.article = article
        self.state = state
    }

}

struct NewsResult: Decodable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Decodable {
    let title: String
    let description: String
    let content: String
    let urlToImage: URL?
}
