//
//  ExploreCell.swift
//  FootballApp
//
//  Created by Servan on 09.10.26.
//

import UIKit

// MARK: - Liqa sətri

final class ExploreLeagueCell: UITableViewCell {

    static let reuseID = "ExploreLeagueCell"

    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view.layer.cornerRadius = 14
        return view
    }()

    private let flagCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view.layer.cornerRadius = 22
        return view
    }()

    private let flagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let countryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        return label
    }()

    private let chevronView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = UIColor.white.withAlphaComponent(0.5)
        imageView.contentMode = .scaleAspectFit
        return imageView
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

    func configure(with league: League) {
        flagLabel.text = league.flag
        nameLabel.text = league.name
        countryLabel.text = league.country
    }

    private func setupViews() {
        let padding = AppLayout.screenPadding.value

        contentView.addSubviews(card)
        card.addSubviews(flagCircle, nameLabel, countryLabel, chevronView)
        flagCircle.addSubviews(flagLabel)

        card
            .top(contentView.topAnchor, 5).0
            .bottom(contentView.bottomAnchor, -5).0
            .leading(contentView.leadingAnchor, padding).0
            .trailing(contentView.trailingAnchor, -padding)

        flagCircle
            .leading(card.leadingAnchor, 14).0
            .top(card.topAnchor, 12).0
            .bottom(card.bottomAnchor, -12).0
            .width(44).0
            .height(44)

        flagLabel
            .centerX(flagCircle.centerXAnchor).0
            .centerY(flagCircle.centerYAnchor)

        chevronView
            .trailing(card.trailingAnchor, -16).0
            .centerY(card.centerYAnchor).0
            .width(12).0
            .height(16)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, countryLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        card.addSubviews(textStack)
        textStack
            .leading(flagCircle.trailingAnchor, 14).0
            .centerY(card.centerYAnchor)
        textStack.trailingAnchor.constraint(lessThanOrEqualTo: chevronView.leadingAnchor, constant: -8).isActive = true
    }
}

// MARK: - Sıralama sətri

final class ExploreRankingCell: UITableViewCell {

    static let reuseID = "ExploreRankingCell"

    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view.layer.cornerRadius = 14
        return view
    }()

    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let flagCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view.layer.cornerRadius = 20
        return view
    }()

    private let flagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22)
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        return label
    }()

    private let pointsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()

    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .right
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

    func configure(with entry: RankingEntry) {
        rankLabel.text = "\(entry.rank)"
        // İlk üç yer vurğulanır.
        rankLabel.textColor = entry.rank <= 3 ? AppGradient.accentStart : UIColor.white.withAlphaComponent(0.7)
        flagLabel.text = entry.flag
        nameLabel.text = entry.name
        subtitleLabel.text = entry.subtitle
        subtitleLabel.isHidden = entry.subtitle == nil
        pointsLabel.text = entry.points

        guard let change = entry.change else {
            changeLabel.isHidden = true
            return
        }
        changeLabel.isHidden = false
        if change > 0 {
            changeLabel.text = "▲ \(change)"
            changeLabel.textColor = .systemGreen
        } else if change < 0 {
            changeLabel.text = "▼ \(abs(change))"
            changeLabel.textColor = .systemRed
        } else {
            changeLabel.text = "–"
            changeLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        }
    }

    private func setupViews() {
        let padding = AppLayout.screenPadding.value

        contentView.addSubviews(card)
        card.addSubviews(rankLabel, flagCircle)
        flagCircle.addSubviews(flagLabel)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let pointsStack = UIStackView(arrangedSubviews: [pointsLabel, changeLabel])
        pointsStack.axis = .vertical
        pointsStack.alignment = .trailing
        pointsStack.spacing = 2
        pointsStack.setContentHuggingPriority(.required, for: .horizontal)
        pointsStack.setContentCompressionResistancePriority(.required, for: .horizontal)

        card.addSubviews(textStack, pointsStack)

        card
            .top(contentView.topAnchor, 5).0
            .bottom(contentView.bottomAnchor, -5).0
            .leading(contentView.leadingAnchor, padding).0
            .trailing(contentView.trailingAnchor, -padding)

        rankLabel
            .leading(card.leadingAnchor, 12).0
            .centerY(card.centerYAnchor).0
            .width(28)

        flagCircle
            .leading(rankLabel.trailingAnchor, 8).0
            .top(card.topAnchor, 12).0
            .bottom(card.bottomAnchor, -12).0
            .width(40).0
            .height(40)

        flagLabel
            .centerX(flagCircle.centerXAnchor).0
            .centerY(flagCircle.centerYAnchor)

        pointsStack
            .trailing(card.trailingAnchor, -14).0
            .centerY(card.centerYAnchor)

        textStack
            .leading(flagCircle.trailingAnchor, 12).0
            .centerY(card.centerYAnchor)
        textStack.trailingAnchor.constraint(lessThanOrEqualTo: pointsStack.leadingAnchor, constant: -8).isActive = true
    }
}

// MARK: - Cədvəl başlığı

/// "#   Club   Pts" sütun başlıqları.
// MARK: - Cədvəl başlığı

/// "#   Club   Pts" sütun başlıqları. Cədvəlin üstündə sabit dayanır, cədvəlin içində yapışqan başlıq deyil.
final class ExploreRankingHeaderView: UIView {

    private let rankLabel = ExploreRankingHeaderView.makeLabel("#", alignment: .center)
    private let nameLabel = ExploreRankingHeaderView.makeLabel("", alignment: .left)
    private let pointsLabel = ExploreRankingHeaderView.makeLabel("Pts", alignment: .right)

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(rankLabel, nameLabel, pointsLabel)
        let padding = AppLayout.screenPadding.value

        // Sütunlar sətirdəki rəqəm, bayraq və xal ilə eyni xətdədir.
        rankLabel
            .leading(leadingAnchor, padding + 12).0
            .centerY(centerYAnchor).0
            .width(28)

        nameLabel
            .leading(leadingAnchor, padding + 12 + 28 + 8 + 40 + 12).0
            .centerY(centerYAnchor)

        pointsLabel
            .trailing(trailingAnchor, -(padding + 14)).0
            .centerY(centerYAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(columnTitle: String) {
        nameLabel.text = columnTitle.uppercased()
    }

    private static func makeLabel(_ text: String, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = alignment
        return label
    }
}
