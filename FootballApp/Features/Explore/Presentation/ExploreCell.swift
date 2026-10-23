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

    /// Oyunçu şəkli; yüklənənə qədər baş hərflər.
    private let photoView = ClubCrestView(size: 40, inset: 0)

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
        photoView.configure(initials: ExploreRankingCell.initials(for: entry.name), imageURL: entry.imageURL)
        nameLabel.text = entry.name
        subtitleLabel.text = entry.subtitle
        subtitleLabel.isHidden = entry.subtitle == nil
        pointsLabel.text = entry.value
    }

    private static func initials(for name: String) -> String {
        name.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
    }

    private func setupViews() {
        let padding = AppLayout.screenPadding.value

        contentView.addSubviews(card)
        card.addSubviews(rankLabel, photoView)
        photoView.clipsToBounds = true

        let textStack = UIStackView(arrangedSubviews: [nameLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let pointsStack = UIStackView(arrangedSubviews: [pointsLabel])
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

        photoView
            .leading(rankLabel.trailingAnchor, 8).0
            .top(card.topAnchor, 12).0
            .bottom(card.bottomAnchor, -12)

        pointsStack
            .trailing(card.trailingAnchor, -14).0
            .centerY(card.centerYAnchor)

        textStack
            .leading(photoView.trailingAnchor, 12).0
            .centerY(card.centerYAnchor)
        textStack.trailingAnchor.constraint(lessThanOrEqualTo: pointsStack.leadingAnchor, constant: -8).isActive = true
    }
}

// MARK: - Cədvəl başlığı

/// "#   Player   Goals" sütun başlıqları. Cədvəlin üstündə sabit dayanır, cədvəlin içində yapışqan başlıq deyil.
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

    func configure(columnTitle: String, valueTitle: String) {
        nameLabel.text = columnTitle.uppercased()
        pointsLabel.text = valueTitle.uppercased()
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
