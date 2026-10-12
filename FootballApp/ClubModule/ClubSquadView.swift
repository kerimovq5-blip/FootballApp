//
//  ClubSquadView.swift
//  FootballApp
//
//  Created by Servan on 11.10.26.
//


//
//  ClubSquadView.swift
//  FootballApp
//

import UIKit

final class ClubSquadView: UIView {
    /// Oyunçu sətrinə toxunanda çağırılır.
    var onSelectPlayer: ((SquadPlayer) -> Void)?
    private struct PositionGroup {
        let position: PlayerPosition
        let players: [SquadPlayer]
    }

    private var groups: [PositionGroup] = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderTopPadding = 0
        tableView.contentInset.bottom = 24
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ClubPlayerCell.self, forCellReuseIdentifier: ClubPlayerCell.reuseID)
        return tableView
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No squad information available."
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

    /// Qapıçılar, müdafiəçilər, yarımmüdafiəçilər, hücumçular sırası ilə; hər qrup forma nömrəsinə görə.
    func configure(with content: ClubDetailContent) {
        groups = PlayerPosition.allCases.compactMap { position in
            let players = content.squad
                .filter { $0.position == position }
                .sorted { $0.number < $1.number }
            return players.isEmpty ? nil : PositionGroup(position: position, players: players)
        }
        emptyLabel.isHidden = !groups.isEmpty
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension ClubSquadView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        groups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups[section].players.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ClubPlayerCell.reuseID, for: indexPath
        ) as? ClubPlayerCell else { return UITableViewCell() }
        cell.configure(with: groups[indexPath.section].players[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ClubSquadView: UITableViewDelegate {

    /// "Goalkeepers" solda, oyunçu sayı sağda.
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let group = groups[section]
        let padding = AppLayout.screenPadding.value

        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.text = group.position.title
        titleLabel.font = AppFonts.semiBold.font
        titleLabel.textColor = .white

        let countLabel = UILabel()
        countLabel.text = "\(group.players.count)"
        countLabel.font = AppFonts.regularBody.font
        countLabel.textColor = UIColor.white.withAlphaComponent(0.6)

        container.addSubviews(titleLabel, countLabel)
        titleLabel
            .leading(container.leadingAnchor, padding).0
            .centerY(container.centerYAnchor)
        countLabel
            .trailing(container.trailingAnchor, -padding).0
            .centerY(container.centerYAnchor)
        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelectPlayer?(groups[indexPath.section].players[indexPath.row])
    }
}

// MARK: - Oyunçu sətri

final class ClubPlayerCell: UITableViewCell {

    static let reuseID = "ClubPlayerCell"

    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view.layer.cornerRadius = 14
        return view
    }()

    private let numberCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view.layer.cornerRadius = 18
        return view
    }()

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
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

    func configure(with player: SquadPlayer) {
        numberLabel.text = "\(player.number)"
        nameLabel.text = player.name
        detailLabel.text = "\(player.flag) \(player.nationality) · \(player.age) yrs"
    }

    private func setupViews() {
        let padding = AppLayout.screenPadding.value

        contentView.addSubviews(card)
        card.addSubviews(numberCircle, nameLabel, detailLabel)
        numberCircle.addSubviews(numberLabel)

        card
            .top(contentView.topAnchor, 5).0
            .bottom(contentView.bottomAnchor, -5).0
            .leading(contentView.leadingAnchor, padding).0
            .trailing(contentView.trailingAnchor, -padding)

        numberCircle
            .leading(card.leadingAnchor, 14).0
            .top(card.topAnchor, 12).0
            .bottom(card.bottomAnchor, -12).0
            .width(36).0
            .height(36)

        numberLabel
            .leading(numberCircle.leadingAnchor, 4).0
            .trailing(numberCircle.trailingAnchor, -4).0
            .centerY(numberCircle.centerYAnchor)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        card.addSubviews(textStack)

        textStack
            .leading(numberCircle.trailingAnchor, 14).0
            .centerY(card.centerYAnchor)
        let chevron = UIImageView(image: UIImage(
            systemName: "chevron.right",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        ))
        chevron.tintColor = UIColor.white.withAlphaComponent(0.4)
        card.addSubviews(chevron)
        chevron
            .trailing(card.trailingAnchor, -16).0
            .centerY(card.centerYAnchor)

        textStack.trailingAnchor
            .constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8)
            .isActive = true
    }
}
