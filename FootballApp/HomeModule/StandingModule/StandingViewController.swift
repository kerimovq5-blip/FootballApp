//
//  StandingViewController.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 02.10.26.
//

import UIKit

final class StandingViewController: UIViewController {

    weak var coordinator: StandingNavigating?

    private let viewModel: StandingViewModel

    init(viewModel: StandingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Standing"
        label.font = AppFonts.title.font
        label.textColor = .white
        return label
    }()

    private lazy var leagueTabBar = PillTabBar(
        titles: viewModel.leagues.map { $0.name },
        alignment: .leading
    )

    private lazy var filterControl: UISegmentedControl = {
        let control = UISegmentedControl(items: StandingFilter.allCases.map { $0.title })
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        control.selectedSegmentTintColor = AppGradient.accentEnd
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.addAction(UIAction { [weak self] action in
            guard let segmented = action.sender as? UISegmentedControl else { return }
            self?.viewModel.select(StandingFilter.allCases[segmented.selectedSegmentIndex])
        }, for: .valueChanged)
        return control
    }()

    private let columnHeader = StandingColumnHeaderView()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
        tableView.dataSource = self
        tableView.register(LeagueStandingCell.self, forCellReuseIdentifier: LeagueStandingCell.reuseID)
        return tableView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AssetColors.background.color
        setupLayout()
        bindViewModel()
        viewModel.load()
    }

    // MARK: - Setup

    private func setupLayout() {
        let padding = AppLayout.screenPadding.value
        view.addSubviews(titleLabel, leagueTabBar, filterControl, columnHeader, tableView)

        titleLabel
            .leading(view.leadingAnchor, padding).0
            .top(view.safeAreaLayoutGuide.topAnchor, AppLayout.mediumSpacing.value)

        leagueTabBar
            .top(titleLabel.bottomAnchor, AppLayout.spacing.value).0
            .leading(view.leadingAnchor, padding).0
            .trailing(view.trailingAnchor, -padding)

        filterControl
            .top(leagueTabBar.bottomAnchor, AppLayout.spacing.value).0
            .leading(view.leadingAnchor, padding).0
            .trailing(view.trailingAnchor, -padding)

        columnHeader
            .top(filterControl.bottomAnchor, AppLayout.spacing.value).0
            .leading(view.leadingAnchor, padding).0
            .trailing(view.trailingAnchor, -padding)

        tableView
            .top(columnHeader.bottomAnchor, AppLayout.smallSpacing.value).0
            .leading(view.leadingAnchor, padding).0
            .trailing(view.trailingAnchor, -padding).0
            .bottom(view.bottomAnchor)
    }

    private func bindViewModel() {
        leagueTabBar.onSelect = { [weak self] index in
            self?.viewModel.selectLeague(at: index)
        }
        viewModel.onChange = { [weak self] in
            self?.reload()
        }
        viewModel.onFailed = { [weak self] message in
            self?.showAlert(message: message)
        }
    }

    private func reload() {
        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
        // Yeni liqa/filtr həmişə yuxarıdan başlasın.
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.adjustedContentInset.top), animated: false)
    }
}

// MARK: - UITableViewDataSource

extension StandingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LeagueStandingCell.reuseID, for: indexPath
        ) as? LeagueStandingCell else { return UITableViewCell() }
        cell.configure(with: viewModel.standings[indexPath.row])
        return cell
    }
}

extension StandingViewController: HidesNavigationBar {}
