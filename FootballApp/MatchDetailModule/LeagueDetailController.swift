//
//  LeagueDetailController.swift
//  FootballApp
//
//  Created by Servan on 01.10.26.
//

import UIKit

final class LeagueDetailController: UIViewController {

    private let league: League
    private let standings: [Standing]
    private var selectedFilter: StandingFilter = .all {
        didSet { tableView.reloadData() }
    }

    init(league: League, standings: [Standing] = LeagueDetailController.mockStandings) {
        self.league = league
        self.standings = standings
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private lazy var backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .white
        b.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return b
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = "\(league.flag) \(league.country)"
        l.font = AppFonts.semiBold.font
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private lazy var crestView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "laLigaCrest"))
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 50
        iv.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        iv.clipsToBounds = true
        return iv
    }()

    private lazy var leagueNameLabel: UILabel = {
        let l = UILabel()
        l.text = league.name
        l.font = AppFonts.titleBold.font
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private lazy var filterButtons: [UIButton] = StandingFilter.allCases.map { filter in
        let b = UIButton(type: .system)
        b.setTitle(filter.title, for: .normal)
        b.titleLabel?.font = AppFonts.semiBold.font
        b.layer.cornerRadius = 18
        b.contentEdgeInsets = UIEdgeInsets(top: 8, left: 18, bottom: 8, right: 18)
        b.tag = StandingFilter.allCases.firstIndex(of: filter) ?? 0
        b.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
        return b
    }

    private lazy var filterStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: filterButtons)
        s.axis = .horizontal
        s.spacing = 10
        return s
    }()
    
    private lazy var columnHeader: UIStackView = {
        let make: (String, NSTextAlignment) -> UILabel = { text, alignment in
            let l = UILabel()
            l.text = text
            l.font = AppFonts.regularBody.font
            l.textColor = UIColor.white.withAlphaComponent(0.5)
            l.textAlignment = alignment
            return l
        }

        let position = make("#", .center); 

        let crestSpacer = UIView()
        crestSpacer.width(20)

        let team = make("Team", .left)
        team.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let headerTeamGroup = UIStackView(arrangedSubviews: [crestSpacer, team])
        headerTeamGroup.axis = .horizontal
        headerTeamGroup.spacing = 8

        let p = make("P", .center); p.width(22)
        let w = make("W", .center); w.width(22)
        let d = make("D", .center); d.width(22)
        let l = make("L", .center); l.width(22)
        let gf = make("GF", .center); gf.width(22)
        let ga = make("GA", .center); ga.width(22)
        let gd = make("GD", .center); gd.width(22)
        let pts = make("Pts", .center); pts.width(28)

        let s = UIStackView(arrangedSubviews: [
            position, headerTeamGroup, p, w, d, l, gf, ga, gd, pts
        ])
        s.axis = .horizontal
        s.spacing = 6
        return s
    }()
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.dataSource = self
        tv.register(LeagueStandingCell.self, forCellReuseIdentifier: LeagueStandingCell.reuseID)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundColor2")
        setupLayout()
        updateFilterAppearance()
        
    }
    private func setupLayout() {
        view.addSubviews(backButton, titleLabel, crestView, leagueNameLabel,
                         filterStack, columnHeader, tableView)

        backButton
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .top(view.safeAreaLayoutGuide.topAnchor, AppLayout.mediumSpacing.value)

        titleLabel
            .centerX(view.centerXAnchor).0
            .centerY(backButton.centerYAnchor)

        crestView
            .centerX(view.centerXAnchor).0
            .top(backButton.bottomAnchor, 24).0
            .width(100).0
            .height(100)

        leagueNameLabel
            .centerX(view.centerXAnchor).0
            .top(crestView.bottomAnchor, 12)

        filterStack
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .top(leagueNameLabel.bottomAnchor, 24)

        columnHeader
            .leading(view.leadingAnchor, AppLayout.screenPadding.value + 12).0
            .trailing(view.trailingAnchor, -(AppLayout.screenPadding.value + 12)).0
            .top(filterStack.bottomAnchor, 24)

        tableView
            .top(columnHeader.bottomAnchor, 8).0
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .bottom(view.bottomAnchor)
    }

    @objc private func backTapped() { navigationController?.popViewController(animated: true) }

    @objc private func filterTapped(_ sender: UIButton) {
        selectedFilter = StandingFilter.allCases[sender.tag]
        updateFilterAppearance()
    }

    private func updateFilterAppearance() {
        for button in filterButtons {
            let isSelected = StandingFilter.allCases[button.tag] == selectedFilter
            button.backgroundColor = isSelected ? UIColor.systemOrange.withAlphaComponent(0.85) : .clear
            button.setTitleColor(.white, for: .normal)
        }
    }
}

extension LeagueDetailController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        standings.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LeagueStandingCell.reuseID, for: indexPath
        ) as? LeagueStandingCell else { return UITableViewCell() }
        cell.configure(with: standings[indexPath.row])
        return cell
    }
}

// Real API gələnə qədər test datası
extension LeagueDetailController {
    static let mockStandings: [Standing] = [
        Standing(position: 1, teamName: "Atlético Madrid", crestImageName: nil, played: 11, wins: 8, draws: 2, losses: 1, goalsFor: 29, goalsAgainst: 6, zone: .championsLeague),
        Standing(position: 2, teamName: "Real Madrid", crestImageName: "realmadrid", played: 11, wins: 7, draws: 4, losses: 3, goalsFor: 22, goalsAgainst: 7,  zone: .championsLeague),
        Standing(position: 3, teamName: "Barcelona", crestImageName: nil, played: 11, wins: 6, draws: 4, losses: 4, goalsFor: 29, goalsAgainst: 9, zone: .championsLeague),
        Standing(position: 4, teamName: "Villareal", crestImageName: nil, played: 11, wins: 5, draws: 8, losses: 2, goalsFor: 26, goalsAgainst: 10,  zone: .none),
        Standing(position: 5, teamName: "Real Sociedad", crestImageName: nil, played: 11, wins: 4, draws: 6, losses: 5, goalsFor: 26, goalsAgainst: 13,  zone: .none),
        Standing(position: 6, teamName: "Sevilla", crestImageName: nil, played: 11, wins: 4, draws: 3, losses: 4, goalsFor: 27, goalsAgainst: 15,  zone: .relegation),
        Standing(position: 7, teamName: "Granada", crestImageName: nil, played: 11, wins: 3, draws: 3, losses: 7, goalsFor: 31, goalsAgainst: 20,  zone: .relegation)
    ]
}

extension LeagueDetailController: HidesNavigationBar {}
