//
//  ArticleCell.swift
//  Feeder
//
//  Created by Steve on 6/14/19.
//  Copyright © 2019 Steve Galbraith. All rights reserved.
//

import UIKit
import RxSwift
import SafariServices

class ArticleCell: UICollectionViewCell {

    private struct Constants {
        static let dateFormat = "MMMM d, yyyy"
        static let titleFont = UIFont(name: "Verdana-Bold", size: 31.0)
        static let titleTextColor = UIColor.white
        static let dateLabelFont = UIFont(name: "Verdana", size: 16.0)
        static let descriptionFont = UIFont(name: "", size: 14.0)
        static let descriptionVerticalSpace: CGFloat = 20.0
        static let descriptionHorizontalInset: CGFloat = 24.0
        static let titleHorizontalInset: CGFloat = 12.0
        static let numberOfSpacesInDescriptionView: CGFloat = 5.0
        static let favoriteButtonFont = UIFont(name: "Verdana", size: 40.0)
        static let webButtonFont = UIFont(name: "Verdana-Bold", size: 16.0)
        static let webButtonHeight: CGFloat = 50.0
        static let contentBottomSpace: CGFloat = 84.0
        static let detailsLabelTopSpace: CGFloat = 4.0
    }

    var descriptionViewHeight: CGFloat = 0.0
    var isShowingDescription = false
    var viewModel: ArticleCellViewModel! {
        didSet {
            configureCell()
        }
    }
    var disposeBag = DisposeBag()

    // MARK: - Views

    let heroImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()

    let titleLabel: UILabel = {
        let label = ShadowedLabel(frame: .zero)
        label.font = Constants.titleFont
        label.textColor = Constants.titleTextColor
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false

        return label
    }()

    let articleInfoView: UIView = {
      return UIView(frame: .zero)
    }()

    let detailsLabel: UILabel = {
        let label = ShadowedLabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.dateLabelFont
        label.textColor = Constants.titleTextColor
        label.isUserInteractionEnabled = false
        label.numberOfLines = 0

        return label
    }()

    let favoriteButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = Constants.favoriteButtonFont
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        button.titleLabel?.layer.shadowRadius = 5.0
        button.titleLabel?.layer.shadowOpacity = 1.0
        button.titleLabel?.layer.shadowOffset = CGSize(width: 1, height: 4)
        button.titleLabel?.layer.masksToBounds = false

        return button
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.descriptionFont
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        
        return label
    }()

    let readOnWebButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame.size.height = 50.0
        button.backgroundColor = .orange
        button.layer.cornerRadius = 10
        button.titleLabel?.font = Constants.webButtonFont

        return button
    }()

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()

        disposeBag = DisposeBag()
        isShowingDescription = false
        descriptionViewHeight = 0
    }

    // MARK: - Configure
    
    func configureCell() {
        clipsToBounds = true
        setupBindings()
        addSubviews()
        addTapGesture()
    }

    // MARK: - Binding
    
    private func setupBindings() {
        bindHeroImage()
        bindLabels()
        bindButtons()
    }

    private func bindHeroImage() {
        viewModel.heroImage
            .asDriver(onErrorJustReturn: UIImage())
            .drive(heroImageView.rx.image)
            .disposed(by: disposeBag)
    }

    private func bindLabels() {
        viewModel.title
            .asDriver(onErrorJustReturn: "")
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)

        Observable.combineLatest(viewModel.source, viewModel.formattedCreatedAt) { "Published by \($0)\r\($1)" }
            .asDriver(onErrorJustReturn: "")
            .drive(detailsLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.isFavorite
            .map { $0 ? "♥️" : "♡" }
            .asDriver(onErrorJustReturn: "")
            .drive(favoriteButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        viewModel.description
            .asDriver(onErrorJustReturn: "")
            .drive(descriptionLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.source
            .map { "READ MORE ON \($0.uppercased())" }
            .asDriver(onErrorJustReturn: "")
            .drive(readOnWebButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
    }

    private func bindButtons() {
        favoriteButton.rx.tap
            .bind { [weak self] _ in
                guard
                    let self = self,
                    let isCurrentlyFavorite = try? self.viewModel.isFavorite.value()
                    else { return }

                self.viewModel.isFavorite.onNext(!isCurrentlyFavorite)
            }
            .disposed(by: disposeBag)

        readOnWebButton.rx.tap
            .bind { [weak self] _ in
                guard
                    let article = try? self?.viewModel.article.value(),
                    let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                    else { return }

                let safariWebView = SFSafariViewController(url: article.link)
                safariWebView.modalPresentationStyle = .overCurrentContext
                rootViewController.present(safariWebView, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Helpers

    private func addSubviews() {
        favoriteButton.sizeToFit()
        contentView.addSubview(heroImageView)
        articleInfoView.addSubview(titleLabel)
        articleInfoView.addSubview(detailsLabel)

        descriptionLabel.frame.size.width = contentView.frame.width - Constants.descriptionHorizontalInset * 2
        descriptionLabel.sizeToFit()
        descriptionViewHeight = Constants.descriptionVerticalSpace * Constants.numberOfSpacesInDescriptionView + descriptionLabel.frame.height + Constants.webButtonHeight
        
        let descriptionView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: contentView.frame.maxY), size: CGSize(width: contentView.frame.width, height: descriptionViewHeight)))
        descriptionView.isUserInteractionEnabled = false
        descriptionView.backgroundColor = .white

        descriptionView.addSubview(descriptionLabel)
        articleInfoView.addSubview(descriptionView)
        contentView.addSubview(articleInfoView)
        contentView.addSubview(readOnWebButton)
        contentView.addSubview(favoriteButton)
        
        NSLayoutConstraint.activate([
            // Title Label
            contentView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.contentBottomSpace),
            contentView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -Constants.titleHorizontalInset),
            contentView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Constants.titleHorizontalInset),

            // Hero Image View
            contentView.topAnchor.constraint(equalTo: heroImageView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: heroImageView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: heroImageView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: heroImageView.trailingAnchor),

            // Details Label
            contentView.leadingAnchor.constraint(equalTo: detailsLabel.leadingAnchor, constant: -Constants.titleHorizontalInset),
            titleLabel.bottomAnchor.constraint(equalTo: detailsLabel.topAnchor, constant: -Constants.detailsLabelTopSpace),
            

            // Favorite Button
            contentView.trailingAnchor.constraint(equalTo: favoriteButton.trailingAnchor, constant: Constants.titleHorizontalInset),
            detailsLabel.centerYAnchor.constraint(equalTo: favoriteButton.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: Constants.webButtonHeight),
            favoriteButton.heightAnchor.constraint(equalToConstant: Constants.webButtonHeight),

            // Description View
            contentView.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor),
            descriptionView.topAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -Constants.descriptionVerticalSpace),
            descriptionView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -Constants.descriptionHorizontalInset),
            descriptionView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant:  Constants.descriptionHorizontalInset),

            // Read on Web Button
            descriptionLabel.bottomAnchor.constraint(equalTo: readOnWebButton.topAnchor, constant: -Constants.descriptionVerticalSpace),
            descriptionView.leadingAnchor.constraint(equalTo: readOnWebButton.leadingAnchor, constant: -Constants.descriptionHorizontalInset),
            descriptionView.trailingAnchor.constraint(equalTo: readOnWebButton.trailingAnchor, constant:  Constants.descriptionHorizontalInset),
            readOnWebButton.heightAnchor.constraint(equalToConstant: Constants.webButtonHeight)
        ])
    }

    private func resetTransformations() {
        articleInfoView.transform = .identity
        readOnWebButton.transform = .identity
        favoriteButton.transform = .identity
    }

    // TODO: Change this to an inturruptible pan gesture animation to slide up descriptionView
    private func addTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        heroImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    // MARK: - Actions

    @objc private func didTap(gesture: UITapGestureRecognizer) {
        let newTransform = !isShowingDescription ? CGAffineTransform(translationX: 0, y: -descriptionViewHeight) : .identity
        isShowingDescription.toggle()
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25) {
                self.articleInfoView.transform = newTransform
                self.readOnWebButton.transform = newTransform
                self.favoriteButton.transform = newTransform
            }
        }
    }
}

class ShadowedLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 1, height: 4)
        layer.masksToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
