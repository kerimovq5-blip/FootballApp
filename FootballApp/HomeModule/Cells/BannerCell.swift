//
//  BannerCell.swift
//  FootballApp
//
//  Created by Servan on 28.09.26.
//

import UIKit

final class BannerCell: UICollectionViewCell {

    static let reuseID = "BannerCell"

    private enum Layout {
        static let cornerRadius = AppRadius.buttonRadiusMedium.radius
        static let pillCornerRadius: CGFloat = 14
        static let padding: CGFloat = 16
        static let imageWidthMultiplier: CGFloat = 0.55
    }

    private let gradientLayer = CAGradientLayer()

    private lazy var backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private lazy var categoryIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "soccerball"))
        iv.tintColor = .black
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.mediumTitle.font
        label.textColor = .black
        return label
    }()

    private lazy var categoryPill: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [categoryIconView, categoryLabel])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 12)
        stack.backgroundColor = .white
        stack.layer.cornerRadius = Layout.pillCornerRadius
        stack.clipsToBounds = true
        return stack
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.titleBold.font
     
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.semiBold.font
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupLayout()
        setupGradient()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
    }

    private func setupHierarchy() {
        contentView.layer.cornerRadius = Layout.cornerRadius
        contentView.clipsToBounds = true
        contentView.addSubviews(backgroundImageView, categoryPill, titleLabel, dateLabel)
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.5).cgColor,
            UIColor(red: 0.05, green: 0.05, blue: 0.35, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        contentView.layer.insertSublayer(gradientLayer, above: backgroundImageView.layer)
    }

    private func setupLayout() {
        backgroundImageView
            .top(contentView.topAnchor).0
            .bottom(contentView.bottomAnchor).0
            .leading(contentView.leadingAnchor).0
            .trailing(contentView.trailingAnchor)

        categoryPill
            .top(contentView.topAnchor, Layout.padding).0
            .leading(contentView.leadingAnchor, Layout.padding)

        categoryIconView.width(18).0.height(18)

        titleLabel
            .leading(contentView.leadingAnchor, Layout.padding).0
            .trailing(contentView.trailingAnchor, -Layout.padding).0
            .top(categoryPill.bottomAnchor, 14)
        titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: dateLabel.topAnchor, constant: -8).isActive = true

        dateLabel
            .leading(contentView.leadingAnchor, Layout.padding).0
            .bottom(contentView.bottomAnchor, -Layout.padding)
    }

    func configure(with banner: Banner) {
        categoryLabel.text = banner.categoryTitle
        titleLabel.text = banner.title
        dateLabel.text = banner.dateText
        backgroundImageView.image = banner.image
    }
}
