//
//  ExploreViewController.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 02.10.26.
//

import UIKit

final class ExploreViewController: UIViewController {

    weak var coordinator: ExploreNavigating?

    private let viewModel: ExploreViewModel

    init(viewModel: ExploreViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private enum Metrics {
        static let columnHeaderHeight: CGFloat = 32
        static let leagueButtonHeight: CGFloat = 36
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Explore"
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .white
        return label
    }()

    private lazy var tabBar = PillTabBar(
        titles: ExploreTab.allCases.map { $0.title },
        alignment: .spread
    )

    /// Reytinq tab-larında liqa seçimi (menyu ilə).
    private lazy var leagueButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor.white.withAlphaComponent(0.08)
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "chevron.down",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
        config.imagePlacement = .trailing
        config.imagePadding = 6
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
        let button = UIButton(configuration: config)
        button.showsMenuAsPrimaryAction = true
        button.isHidden = true
        return button
    }()
    private var leagueButtonHeight: NSLayoutConstraint?

    private let columnHeader = ExploreRankingHeaderView()
    private var columnHeaderHeight: NSLayoutConstraint?

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ExploreLeagueCell.self, forCellReuseIdentifier: ExploreLeagueCell.reuseID)
        tableView.register(ExploreRankingCell.self, forCellReuseIdentifier: ExploreRankingCell.reuseID)
        return tableView
    }()

    /// Siyahının yerində: yüklənir və ya xəta + "Try again".
    private lazy var stateView: StateView = {
        let stateView = StateView()
        stateView.onRetry = { [weak self] in
            self?.showLoading()
            self?.viewModel.retry()
        }
        return stateView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AssetColors.background.color
        setupLayout()
        bindViewModel()
        showLoading()
        viewModel.load()
    }

    // MARK: - Setup

    private func setupLayout() {
        let padding = AppLayout.screenPadding.value
        view.addSubviews(titleLabel, tabBar, leagueButton, columnHeader, tableView, stateView)

        titleLabel
            .leading(view.leadingAnchor, padding).0
            .top(view.safeAreaLayoutGuide.topAnchor, AppLayout.mediumSpacing.value)

        tabBar
            .top(titleLabel.bottomAnchor, AppLayout.spacing.value).0
            .leading(view.leadingAnchor, padding).0
            .trailing(view.trailingAnchor, -padding)

        leagueButton
            .top(tabBar.bottomAnchor, AppLayout.smallSpacing.value).0
            .leading(view.leadingAnchor, padding)
        leagueButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -padding).isActive = true
        let buttonHeight = leagueButton.heightAnchor.constraint(equalToConstant: 0)
        buttonHeight.isActive = true
        leagueButtonHeight = buttonHeight

        columnHeader
            .top(leagueButton.bottomAnchor, AppLayout.smallSpacing.value).0
            .leading(view.leadingAnchor).0
            .trailing(view.trailingAnchor)
        let heightConstraint = columnHeader.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
        columnHeaderHeight = heightConstraint

        tableView
            .top(columnHeader.bottomAnchor).0
            .leading(view.leadingAnchor).0
            .trailing(view.trailingAnchor).0
            .bottom(view.bottomAnchor)

        stateView.pinEdges(to: tableView)
    }

    private func bindViewModel() {
        tabBar.onSelect = { [weak self] index in
            self?.viewModel.select(ExploreTab.allCases[index])
        }
        viewModel.onChange = { [weak self] in
            self?.reload()
        }
        viewModel.onLoading = { [weak self] in
            self?.updateHeader()
            self?.showLoading()
        }
        viewModel.onFailed = { [weak self] error in
            self?.tableView.isHidden = true
            self?.stateView.show(error)
        }
    }

    private func showLoading() {
        tableView.isHidden = true
        stateView.showLoading()
    }

    private func reload() {
        stateView.hide()
        tableView.isHidden = false
        updateHeader()
        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        })
        // Yeni tab həmişə yuxarıdan başlasın.
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.adjustedContentInset.top), animated: false)
    }

    /// Reytinq tab-larında liqa seçimi və "# PLAYER GOALS" başlığı görünür, Leagues tab-ında gizlənir.
    private func updateHeader() {
        if let kind = viewModel.selectedTab.topPlayersKind {
            columnHeader.configure(columnTitle: "Player", valueTitle: kind.valueTitle)
            columnHeader.isHidden = false
            columnHeaderHeight?.constant = Metrics.columnHeaderHeight
            updateLeagueButton()
            leagueButton.isHidden = false
            leagueButtonHeight?.constant = Metrics.leagueButtonHeight
        } else {
            columnHeader.isHidden = true
            columnHeaderHeight?.constant = 0
            leagueButton.isHidden = true
            leagueButtonHeight?.constant = 0
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    private func updateLeagueButton() {
        let selected = viewModel.selectedLeague
        leagueButton.configuration?.title = selected.map { "\($0.flag) \($0.name)" } ?? "League"
        let actions = viewModel.leagues.enumerated().map { index, league in
            UIAction(title: "\(league.flag) \(league.name)",
                     state: league.id == selected?.id ? .on : .off) { [weak self] _ in
                self?.viewModel.selectLeague(at: index)
            }
        }
        leagueButton.menu = UIMenu(children: actions)
    }
}

// MARK: - UITableViewDataSource

extension ExploreViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.selectedTab == .leagues {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ExploreLeagueCell.reuseID, for: indexPath
            ) as? ExploreLeagueCell else { return UITableViewCell() }
            cell.configure(with: viewModel.leagues[indexPath.row])
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ExploreRankingCell.reuseID, for: indexPath
        ) as? ExploreRankingCell else { return UITableViewCell() }
        cell.configure(with: viewModel.rankings[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ExploreViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch viewModel.selectedTab {
        case .leagues:
            coordinator?.showLeagueDetail(for: viewModel.leagues[indexPath.row])
        case .topScorers, .topAssists:
            guard let player = viewModel.rankings[indexPath.row].player else { return }
            coordinator?.showPlayerDetail(for: player)
        }
    }
}

extension ExploreViewController: HidesNavigationBar {}
