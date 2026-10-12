//
//  PlayerMatchesView.swift
//  FootballApp
//
//  Created by Servan on 12.10.26.
//


//
//  PlayerMatchesView.swift
//  FootballApp
//

import UIKit

final class PlayerMatchesView: UIView {

    /// Yalnız oyun detalı olan oyunlarda çağırılır.
    var onSelectMatch: ((Int) -> Void)?

    private var matches: [PlayerMatch] = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderTopPadding = 0
        tableView.contentInset.bottom = 24
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PlayerMatchCell.self, forCellReuseIdentifier: PlayerMatchCell.reuseID)
        return tableView
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No matches available."
        label.font = AppFonts.regularBody.font
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(tableView, emptyLabel)

        tableView
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor)

        emptyLabel
            .top(topAnchor, 60).0
            .leading(leadingAnchor, 40).0
            .trailing(trailingAnchor, -40)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with content: PlayerDetailContent) {
        matches = content.matches
        emptyLabel.isHidden = !matches.isEmpty
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension PlayerMatchesView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        matches.isEmpty ? 0 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PlayerMatchCell.reuseID, for: indexPath
        ) as? PlayerMatchCell else { return UITableViewCell() }
        cell.configure(with: matches[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PlayerMatchesView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let id = matches[indexPath.row].matchID else { return }
        onSelectMatch?(id)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        let label = InfoUI.label("Recent matches", font: AppFonts.semiBold.font, color: .white)
        container.addSubviews(label)
        label
            .leading(container.leadingAnchor, AppLayout.screenPadding.value).0
            .centerY(container.centerYAnchor)
        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
}

// MARK: - Oyun sətri

final class PlayerMatchCell: UITableViewCell {

    static let reuseID = "PlayerMatchCell"

    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view.layer.cornerRadius = 14
        return view
    }()

    private let captionLabel = InfoUI.label("", font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                            color: UIColor.white.withAlphaComponent(0.6))

    private let scoreLabel: UILabel = {
        let label = InfoUI.label("", font: UIFont.systemFont(ofSize: 15, weight: .semibold), color: .white)
        label.numberOfLines = 0
        return label
    }()

    private let detailLabel: UILabel = {
        let label = InfoUI.label("", font: UIFont.systemFont(ofSize: 13, weight: .regular),
                                 color: UIColor.white.withAlphaComponent(0.7))
        label.numberOfLines = 0
        return label
    }()

    private let ratingBadge: UILabel = {
        let label = InfoUI.label("", font: UIFont.systemFont(ofSize: 14, weight: .bold), color: .white)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
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

    func configure(with match: PlayerMatch) {
        captionLabel.text = "\(match.dateText) · \(match.competition)"

        if let home = match.homeScore, let away = match.awayScore {
            scoreLabel.text = "\(match.home)  \(home) - \(away)  \(match.away)"
        } else {
            scoreLabel.text = "\(match.home)  vs  \(match.away)"
        }

        var parts = [match.didPlay ? "\(match.minutes)'" : "Did not play"]
        if match.goals > 0 { parts.append(match.goals == 1 ? "1 goal" : "\(match.goals) goals") }
        if match.assists > 0 { parts.append(match.assists == 1 ? "1 assist" : "\(match.assists) assists") }
        if match.yellowCards > 0 { parts.append("🟨") }
        if match.redCards > 0 { parts.append("🟥") }
        detailLabel.text = parts.joined(separator: " · ")

        if let rating = match.rating {
            ratingBadge.isHidden = false
            ratingBadge.text = PlayerRating.text(rating)
            ratingBadge.backgroundColor = PlayerRating.color(rating)
        } else {
            ratingBadge.isHidden = true
        }
    }

    private func setupViews() {
        let padding = AppLayout.screenPadding.value

        contentView.addSubviews(card)
        card.addSubviews(captionLabel, scoreLabel, detailLabel, ratingBadge)

        card
            .top(contentView.topAnchor, 5).0
            .bottom(contentView.bottomAnchor, -5).0
            .leading(contentView.leadingAnchor, padding).0
            .trailing(contentView.trailingAnchor, -padding)

        ratingBadge
            .trailing(card.trailingAnchor, -16).0
            .centerY(card.centerYAnchor).0
            .width(44).0
            .height(28)

        captionLabel
            .top(card.topAnchor, 12).0
            .leading(card.leadingAnchor, 16)

        scoreLabel
            .top(captionLabel.bottomAnchor, 6).0
            .leading(card.leadingAnchor, 16)

        detailLabel
            .top(scoreLabel.bottomAnchor, 4).0
            .leading(card.leadingAnchor, 16).0
            .bottom(card.bottomAnchor, -12)

        [captionLabel, scoreLabel, detailLabel].forEach {
            $0.trailingAnchor
                .constraint(lessThanOrEqualTo: ratingBadge.leadingAnchor, constant: -8)
                .isActive = true
        }
    }
}