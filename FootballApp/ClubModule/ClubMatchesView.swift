//
//  ClubMatchesView.swift
//  FootballApp
//
//  Created by Servan on 11.10.26.
//

//
//  ClubMatchesView.swift
//  FootballApp
//

import UIKit

final class ClubMatchesView: UIView {

    /// Yalnız oyun detalı olan oyunlarda çağırılır.
    var onSelectMatch: ((Int) -> Void)?

    private struct MatchGroup {
        let title: String
        let matches: [ClubMatch]
        let showsResult: Bool
    }

    private var groups: [MatchGroup] = []
    private var clubKey = ""

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderTopPadding = 0
        tableView.contentInset.bottom = 24
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ClubMatchCell.self, forCellReuseIdentifier: ClubMatchCell.reuseID)
        return tableView
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No matches available."
        label.font = .regularBody
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

    func configure(with content: ClubDetailContent) {
        clubKey = ClubKey.make(content.profile.name)
        groups = []
        if !content.upcoming.isEmpty {
            groups.append(MatchGroup(title: "Upcoming", matches: content.upcoming, showsResult: false))
        }
        if !content.results.isEmpty {
            groups.append(MatchGroup(title: "Results", matches: content.results, showsResult: true))
        }
        emptyLabel.isHidden = !groups.isEmpty
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension ClubMatchesView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        groups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups[section].matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ClubMatchCell.reuseID, for: indexPath
        ) as? ClubMatchCell else { return UITableViewCell() }

        let group = groups[indexPath.section]
        let match = group.matches[indexPath.row]
        cell.configure(with: match, result: group.showsResult ? match.result(for: clubKey) : nil)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ClubMatchesView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let id = groups[indexPath.section].matches[indexPath.row].matchID else { return }
        onSelectMatch?(id)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        let label = UILabel()
        label.text = groups[section].title
        label.font = .semiBold
        label.textColor = .white
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

final class ClubMatchCell: UITableViewCell {

    static let reuseID = "ClubMatchCell"

    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view.layer.cornerRadius = 14
        return view
    }()

    private let resultBar: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        return view
    }()

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        return label
    }()

    private let homeLabel = ClubMatchCell.makeTeamLabel()
    private let awayLabel = ClubMatchCell.makeTeamLabel()

    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private lazy var teamsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [homeLabel, awayLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
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

    func configure(with match: ClubMatch, result: ClubResult?) {
        captionLabel.text = "\(match.dateText) · \(match.competition)"
        homeLabel.text = match.home
        awayLabel.text = match.away

        if let home = match.homeScore, let away = match.awayScore {
            scoreLabel.text = "\(home) - \(away)"
        } else {
            scoreLabel.text = ""
        }

        statusLabel.text = match.statusText
        statusLabel.textColor = match.isLive ? .systemGreen : UIColor.white.withAlphaComponent(0.6)

        resultBar.isHidden = result == nil
        resultBar.backgroundColor = result?.color ?? .clear
    }

    private func setupViews() {
        let padding = AppLayout.screenPadding.value

        contentView.addSubviews(card)
        card.addSubviews(resultBar, captionLabel, teamsStack, scoreLabel, statusLabel)

        card
            .top(contentView.topAnchor, 5).0
            .bottom(contentView.bottomAnchor, -5).0
            .leading(contentView.leadingAnchor, padding).0
            .trailing(contentView.trailingAnchor, -padding)

        resultBar
            .leading(card.leadingAnchor, 8).0
            .top(card.topAnchor, 12).0
            .bottom(card.bottomAnchor, -12).0
            .width(4)

        captionLabel
            .top(card.topAnchor, 12).0
            .leading(resultBar.trailingAnchor, 12).0
            .trailing(card.trailingAnchor, -16)

        teamsStack
            .top(captionLabel.bottomAnchor, 8).0
            .leading(captionLabel.leadingAnchor).0
            .bottom(card.bottomAnchor, -12)

        statusLabel
            .trailing(card.trailingAnchor, -16).0
            .centerY(teamsStack.centerYAnchor).0
            .width(56)

        scoreLabel
            .trailing(statusLabel.leadingAnchor, -8).0
            .centerY(teamsStack.centerYAnchor)

        teamsStack.trailingAnchor
            .constraint(lessThanOrEqualTo: scoreLabel.leadingAnchor, constant: -8)
            .isActive = true
    }

    private static func makeTeamLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        return label
    }
}
