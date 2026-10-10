//
//  LeagueDetailController.swift
//  FootballApp
//
//  Created by Servan on 01.10.26.
//

import UIKit

final class LeagueDetailController: UIViewController {

    private let league: League
    private let service: StandingProviding
    private var standings: [Standing] = []
    private var selectedFilter: StandingFilter = .all {
        didSet { loadStandings() }
    }

    init(league: League, service: StandingProviding = MockStandingService()) {
        self.league = league
        self.service = service
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

    private let columnHeader = StandingColumnHeaderView()

    private lazy var messageLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.body.font
        l.textColor = UIColor.white.withAlphaComponent(0.6)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
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
        loadStandings()
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

        // Başlığın öz içində 12 pt kənar boşluğu var, ona görə cədvəllə eyni enə qoyulur.
        columnHeader
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .top(filterStack.bottomAnchor, 24)

        tableView
            .top(columnHeader.bottomAnchor, 8).0
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .bottom(view.bottomAnchor)
    }

    private func loadStandings() {
        service.fetchStandings(for: league, filter: selectedFilter) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let standings):
                self.standings = standings
                self.tableView.backgroundView = nil
            case .failure(let error):
                self.standings = []
                self.messageLabel.text = error.localizedDescription
                self.tableView.backgroundView = self.messageLabel
            }
            self.tableView.reloadData()
        }
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

extension LeagueDetailController: HidesNavigationBar {}
