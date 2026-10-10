//
//  SearchRowCell.swift
//  FootballApp
//
//  Created by Servan on 10.10.26.
//


//
//  SearchRowCell.swift
//  FootballApp
//

import UIKit

final class SearchRowCell: UICollectionViewCell {

    static let reuseID = "SearchRowCell"

    enum Icon {
        case emoji(String)
        case symbol(String)
    }

    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view.layer.cornerRadius = 14
        return view
    }()

    private let iconCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view.layer.cornerRadius = 20
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()

    private let symbolView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor.white.withAlphaComponent(0.7)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        return label
    }()

    private let accessoryView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor.white.withAlphaComponent(0.5)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubviews(card)
        card.addSubviews(iconCircle, textStack, accessoryView)
        iconCircle.addSubviews(emojiLabel, symbolView)

        card
            .top(contentView.topAnchor).0
            .leading(contentView.leadingAnchor).0
            .trailing(contentView.trailingAnchor).0
            .bottom(contentView.bottomAnchor)

        iconCircle
            .leading(card.leadingAnchor, 14).0
            .top(card.topAnchor, 12).0
            .bottom(card.bottomAnchor, -12).0
            .width(40).0
            .height(40)

        emojiLabel
            .centerX(iconCircle.centerXAnchor).0
            .centerY(iconCircle.centerYAnchor)

        symbolView
            .centerX(iconCircle.centerXAnchor).0
            .centerY(iconCircle.centerYAnchor).0
            .width(20).0
            .height(20)

        accessoryView
            .trailing(card.trailingAnchor, -16).0
            .centerY(card.centerYAnchor).0
            .width(14).0
            .height(14)

        textStack
            .leading(iconCircle.trailingAnchor, 12).0
            .centerY(card.centerYAnchor)
        textStack.trailingAnchor
            .constraint(lessThanOrEqualTo: accessoryView.leadingAnchor, constant: -8)
            .isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet { card.alpha = isHighlighted ? 0.7 : 1 }
    }

    func configure(icon: Icon, title: String, subtitle: String?, accessorySymbol: String) {
        switch icon {
        case .emoji(let value):
            emojiLabel.text = value
            emojiLabel.isHidden = false
            symbolView.isHidden = true
        case .symbol(let name):
            symbolView.image = UIImage(systemName: name)
            symbolView.isHidden = false
            emojiLabel.isHidden = true
        }
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil

        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        accessoryView.image = UIImage(systemName: accessorySymbol, withConfiguration: config)
    }
}