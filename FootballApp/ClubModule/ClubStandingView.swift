//
//  ClubStandingView.swift
//  FootballApp
//
//  Created by Servan on 11.10.26.
//


//
//  ClubStandingView.swift
//  FootballApp
//

import UIKit

final class ClubStandingView: UIView {

    /// Başqa klubun sətrinə toxunanda klubun adı ötürülür.
    var onSelectClub: ((String) -> Void)?

    private var tables: [ClubTable] = []
    private var selectedIndex = 0
    private var clubKey = ""
    private var needsReveal = false

    private var standings: [Standing] {
        tables.indices.contains(selectedIndex) ? tables[selectedIndex].standings : []
    }

    // MARK: - Views

    private let selectorLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.semiBold.font
        label.textColor = .white
        return label
    }()

    private let chevronView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.up.chevron.down"))
        imageView.tintColor = UIColor.white.withAlphaComponent(0.6)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let selectorButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        button.layer.cornerRadius = 14
        return button
    }()

    private let columnHeader = StandingColumnHeaderView()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset.bottom = 24
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LeagueStandingCell.self, forCellReuseIdentifier: LeagueStandingCell.reuseID)
        return tableView
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No standings available for this club."
        label.font = AppFonts.regularBody.font
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        let padding = AppLayout.screenPadding.value

        addSubviews(selectorButton, columnHeader, tableView, emptyLabel)
        selectorButton.addSubviews(selectorLabel, chevronView)

        selectorButton
            .top(topAnchor).0
            .leading(leadingAnchor, padding).0
            .trailing(trailingAnchor, -padding).0
            .height(48)

        selectorLabel
            .leading(selectorButton.leadingAnchor, 16).0
            .centerY(selectorButton.centerYAnchor)
        selectorLabel.trailingAnchor
            .constraint(lessThanOrEqualTo: chevronView.leadingAnchor, constant: -8)
            .isActive = true

        chevronView
            .trailing(selectorButton.trailingAnchor, -16).0
            .centerY(selectorButton.centerYAnchor).0
            .width(14).0
            .height(18)

        columnHeader
            .top(selectorButton.bottomAnchor, 16).0
            .leading(leadingAnchor, padding).0
            .trailing(trailingAnchor, -padding)

        tableView
            .top(columnHeader.bottomAnchor, 8).0
            .leading(leadingAnchor, padding).0
            .trailing(trailingAnchor, -padding).0
            .bottom(bottomAnchor)

        emptyLabel
            .top(topAnchor, 60).0
            .leading(leadingAnchor, 40).0
            .trailing(trailingAnchor, -40)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - API

    func configure(with content: ClubDetailContent) {
        tables = content.tables
        clubKey = ClubKey.make(content.profile.name)
        selectedIndex = 0

        let hasTables = !tables.isEmpty
        selectorButton.isHidden = !hasTables
        columnHeader.isHidden = !hasTables
        tableView.isHidden = !hasTables
        emptyLabel.isHidden = hasTables

        guard hasTables else { return }
        updateSelector()
        tableView.reloadData()
        needsReveal = true
    }

    /// Tab görünəndə klubun öz sətrini cədvəlin ortasına gətirir.
    func revealClub() {
        guard needsReveal,
              let row = standings.firstIndex(where: { ClubKey.make($0.teamName) == clubKey }) else { return }
        layoutIfNeeded()
        needsReveal = false
        tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .middle, animated: false)
    }

    // MARK: - Private

    private func select(_ index: Int) {
        selectedIndex = index
        updateSelector()
        tableView.reloadData()
        needsReveal = true
        if !isHidden { revealClub() }
    }

    private func updateSelector() {
        guard tables.indices.contains(selectedIndex) else { return }
        let league = tables[selectedIndex].league
        selectorLabel.text = "\(league.flag)  \(league.name)"

        let hasChoice = tables.count > 1
        chevronView.isHidden = !hasChoice
        selectorButton.showsMenuAsPrimaryAction = hasChoice
        selectorButton.menu = hasChoice ? makeMenu() : nil
    }

    private func makeMenu() -> UIMenu {
        let actions = tables.enumerated().map { index, table in
            UIAction(title: "\(table.league.flag) \(table.league.name)",
                     state: index == selectedIndex ? .on : .off) { [weak self] _ in
                self?.select(index)
            }
        }
        return UIMenu(children: actions)
    }
}

// MARK: - UITableViewDataSource

extension ClubStandingView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        standings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LeagueStandingCell.reuseID, for: indexPath
        ) as? LeagueStandingCell else { return UITableViewCell() }

        let standing = standings[indexPath.row]
        cell.configure(with: standing, isHighlighted: ClubKey.make(standing.teamName) == clubKey)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ClubStandingView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let standing = standings[indexPath.row]
        // Klubun öz sətri ona eyni səhifəni yenidən açmasın.
        guard ClubKey.make(standing.teamName) != clubKey else { return }
        onSelectClub?(standing.teamName)
    }
}