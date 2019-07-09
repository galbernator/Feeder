//
//  DashboardViewController.swift
//  Feeder
//
//  Created by Steve on 6/14/19.
//  Copyright © 2019 Steve Galbraith. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DashboardViewController: UIViewController {

    // MARK: - Properties

    let viewModel = DashboardViewModel()
    let disposeBag = DisposeBag()

    var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        return UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()

    var iconButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 27
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIColor.lightGray
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 3
        button.layer.shadowOffset = CGSize(width: 2, height: 4)
        button.layer.shadowOpacity = 1
        button.titleLabel?.font = UIFont(name: "Verdana", size: 32)

        return button
    }()
    var favoritesTextButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 22)
        button.layer.cornerRadius = 18.0
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = UIColor.lightGray
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 3
        button.layer.shadowOffset = CGSize(width: 2, height: 4)
        button.layer.shadowOpacity = 1
        button.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14.0)
        button.titleLabel?.textColor = UIColor.darkGray

        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        setupCollectionView()
        addFavoritesButton()
    }

    // MARK: - Setup

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.register(ArticleCell.self, forCellWithReuseIdentifier: "ArticleCell")
        collectionView.isPagingEnabled = true
        addCollectionView()
    }

    private func addCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 20.0),
            view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -20.0),
            view.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor)
        ])
    }

    private func addFavoritesButton() {
        favoritesTextButton.sizeToFit()
        view.addSubview(favoritesTextButton)
        view.addSubview(iconButton)
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: iconButton.topAnchor, constant: -12.0),
            view.trailingAnchor.constraint(equalTo: iconButton.trailingAnchor, constant: 12.0),
            iconButton.widthAnchor.constraint(equalToConstant: 54),
            iconButton.heightAnchor.constraint(equalToConstant: 54),
            iconButton.centerYAnchor.constraint(equalTo: favoritesTextButton.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: favoritesTextButton.trailingAnchor, constant: 42.0),
            favoritesTextButton.widthAnchor.constraint(equalToConstant: 220)
        ])
    }

    // MARK: - Binding

    private func bindViewModel() {
        bindCollectionView()
        bindFavoritesButton()
    }

    private func bindCollectionView() {
        viewModel.displayedArticles
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(cellIdentifier: "ArticleCell", cellType: ArticleCell.self)) { [weak self] _, article, cell in
                cell.viewModel = self?.viewModel.viewModel(for: article)
            }
            .disposed(by: disposeBag)
    }

    private func bindFavoritesButton() {
        viewModel.favoritesButtonText
            .asDriver(onErrorJustReturn: "")
            .drive(favoritesTextButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        viewModel.iconButtonText
            .asDriver(onErrorJustReturn: "")
            .drive(iconButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        Observable.merge(favoritesTextButton.rx.tap.asObservable(), iconButton.rx.tap.asObservable())
            .bind { [weak self] _ in
                guard
                    let self = self,
                    let isShowingFavorites = try? self.viewModel.showOnlyFavorites.value()
                    else { return }

                self.viewModel.showOnlyFavorites.onNext(!isShowingFavorites)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - FlowLayout Delegate

extension DashboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: collectionView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
