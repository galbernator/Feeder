//
//  DashboardViewModel.swift
//  Feeder
//
//  Created by Steve on 6/14/19.
//  Copyright © 2019 Steve Galbraith. All rights reserved.
//

import Foundation
import RxSwift

struct DashboardViewModel {

    private struct Constants {
        static let showFavoritesText = "SHOW FAVORITES"
        static let showFavoritesEmoji = "♥️"
        static let showArticlesText = "SHOW ALL ARTICLES"
        static let showArticlesEmoji = "📰"
    }

    private let articles = BehaviorSubject<[Article]>(value: [])
    let displayedArticles = BehaviorSubject<[Article]>(value: [])
    let showOnlyFavorites = BehaviorSubject<Bool>(value: false)
    let favoritesButtonText = BehaviorSubject<String>(value: Constants.showFavoritesText)
    let iconButtonText = BehaviorSubject<String>(value: Constants.showFavoritesEmoji)
    let disposeBag = DisposeBag()

    init() {
        Observable.combineLatest(articles, showOnlyFavorites) { $1 ? $0.filter { $0.favorite } : $0 }
            .skip(1)
            .subscribe(onNext: { [unowned displayedArticles] articles in
                displayedArticles.onNext(articles)
            })
            .disposed(by: disposeBag)

        showOnlyFavorites
            .map { $0 ? Constants.showArticlesText : Constants.showFavoritesText }
            .subscribe(onNext: { [unowned favoritesButtonText] text in
                favoritesButtonText.onNext(text)
            })
            .disposed(by: disposeBag)

        showOnlyFavorites
            .map { $0 ? Constants.showArticlesEmoji : Constants.showFavoritesEmoji }
            .subscribe(onNext: { [unowned iconButtonText] text in
                iconButtonText.onNext(text)
            })
            .disposed(by: disposeBag)

        guard
            let articlePath = Bundle.main.path(forResource: "articles", ofType: "json")
            else { return }

        do {
            let articleData = try Data(contentsOf: URL(fileURLWithPath: articlePath), options: .mappedIfSafe)
            Observable.just(articleData)
                .map { json in
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let response = try decoder.decode(ArticlesResponse.self, from: json)
                    return response.articles
                }
                .subscribe(onNext: { [unowned articles] updatedArticles in
                    articles.onNext(updatedArticles)
                })
                .disposed(by: disposeBag)
        } catch {
            print("Failed to read article data from file")
        }
    }

    func viewModel(for article: Article) -> ArticleCellViewModel {
        let viewModel = ArticleCellViewModel()
        viewModel.article.onNext(article)
        viewModel.isFavorite.onNext(article.favorite)

        viewModel.article
            .map { [unowned articles] article -> [Article]? in
                guard
                    let article = article,
                    var currentArticles = try? articles.value(),
                    let articleIndex = currentArticles.firstIndex(where: { $0.id == article.id }),
                    currentArticles[articleIndex].favorite != article.favorite
                    else { return nil }

                currentArticles[articleIndex] = article
                return currentArticles
            }
            .subscribe(onNext: { [unowned articles] updatedArticles in
                guard let updatedArticles = updatedArticles else { return }
                articles.onNext(updatedArticles)
            })
            .disposed(by: viewModel.disposeBag)
        
        return viewModel
    }
}
