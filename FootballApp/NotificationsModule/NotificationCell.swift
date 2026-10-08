//
//  NotificationCell.swift
//  FootballApp
//
//  Created by Servan on 08.10.26.
//

import UIKit

final class NotificationCell: UITableViewCell {

    static let reuseID = "NotificationCell"

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

    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.numberOfLines = 0
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        card.alpha = highlighted ? 0.7 : 1
    }

    func configure(with item: MatchNotification) {
        iconLabel.text = item.icon
        titleLabel.text = item.title
        messageLabel.text = item.message
        timeLabel.text = item.time
    }

    private func setupViews() {
        let padding = AppLayout.screenPadding.value

        contentView.addSubviews(card)
        card.addSubviews(iconCircle, titleLabel, messageLabel, timeLabel)
        iconCircle.addSubviews(iconLabel)

        card
            .top(contentView.topAnchor, 5).0
            .bottom(contentView.bottomAnchor, -5).0
            .leading(contentView.leadingAnchor, padding).0
            .trailing(contentView.trailingAnchor, -padding)

        iconCircle
            .leading(card.leadingAnchor, 14).0
            .top(card.topAnchor, 14).0
            .width(40).0
            .height(40)

        iconLabel
            .centerX(iconCircle.centerXAnchor).0
            .centerY(iconCircle.centerYAnchor)

        timeLabel
            .top(card.topAnchor, 16).0
            .trailing(card.trailingAnchor, -14)

        titleLabel
            .top(card.topAnchor, 14).0
            .leading(iconCircle.trailingAnchor, 12)
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8).isActive = true

        messageLabel
            .top(titleLabel.bottomAnchor, 4).0
            .leading(titleLabel.leadingAnchor).0
            .trailing(card.trailingAnchor, -14).0
            .bottom(card.bottomAnchor, -14)
    }
}

/// Hər oyunun bildirişlərinin üstündəki başlıq: oyun və liqa adı.
final class NotificationGroupHeaderView: UITableViewHeaderFooterView {

    static let reuseID = "NotificationGroupHeaderView"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        // Başlıq yapışqan olduğu üçün fon tam örtücüdür; altından keçən sətirlər görünmür.
        contentView.backgroundColor = AssetColors.background.color

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        contentView.addSubviews(stack)

        let padding = AppLayout.screenPadding.value
        stack
            .top(contentView.topAnchor, 16).0
            .bottom(contentView.bottomAnchor, -8).0
            .leading(contentView.leadingAnchor, padding).0
            .trailing(contentView.trailingAnchor, -padding)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
