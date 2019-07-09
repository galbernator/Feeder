//
//  ArticleCellViewModel.swift
//  Feeder
//
//  Created by Steve on 6/15/19.
//  Copyright © 2019 Steve Galbraith. All rights reserved.
//

import Foundation
import RxSwift

struct ArticleCellViewModel {

    private struct Constants {
        static let dateFormat = "MMMM d yyyy"
    }

    let article = BehaviorSubject<Article?>(value: nil)
    let heroImage = BehaviorSubject<UIImage>(value: UIImage())
    let title = BehaviorSubject<String>(value: "")
    let source = BehaviorSubject<String>(value: "")
    let formattedCreatedAt = BehaviorSubject<String>(value: "")
    let isFavorite = BehaviorSubject<Bool>(value: false)
    let description = BehaviorSubject<String>(value: "")
    let disposeBag = DisposeBag()

    init() {
        article
            .filter { $0 != nil }
            .map { $0!.heroImage  }
            .map { try? Data(contentsOf: $0) }
            .filter { $0 != nil }
            .map { UIImage(data: $0!)! }
            .subscribe(onNext: { [unowned heroImage] articleImage in
                heroImage.onNext(articleImage)
            })
            .disposed(by: disposeBag)
        
        article
            .filter { $0 != nil }
            .map { $0!.title }
            .subscribe(onNext: { [unowned title] articleTitle in
                title.onNext(articleTitle)
            })
            .disposed(by: disposeBag)

        article
            .filter { $0 != nil }
            .map { $0!.source }
            .subscribe(onNext: { [unowned source] articleSource in
                source.onNext(articleSource)
            })
            .disposed(by: disposeBag)

        article
            .filter { $0 != nil }
            .map { $0!.createdAt }
            .map { date in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = Constants.dateFormat
                return dateFormatter.string(from: date)
            }
            .subscribe(onNext: { [unowned formattedCreatedAt] articleCreatedAt in
                formattedCreatedAt.onNext(articleCreatedAt)
            })
            .disposed(by: disposeBag)

        article
            .filter { $0 != nil }
            .map { $0!.description }
            .subscribe(onNext: { [unowned description] articleDescription in
                description.onNext(articleDescription)
            })
            .disposed(by: disposeBag)

        isFavorite
            .skip(1)
            .withLatestFrom(article) { (article: $1, isFavorite: $0) }
            .filter { $0.article != nil }
            .filter { $0.article!.favorite != $0.isFavorite }
            .map { tuple -> Article in
                var article = tuple.article!
                article.favorite = tuple.isFavorite
                return article
            }
            .subscribe(onNext: { [unowned article] updatedArticle in
                article.onNext(updatedArticle)
            })
            .disposed(by: disposeBag)
    }
}
