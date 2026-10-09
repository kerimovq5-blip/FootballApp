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
        view.addSubviews(titleLabel, tabBar, columnHeader, tableView)

        titleLabel
            .leading(view.leadingAnchor, padding).0
            .top(view.safeAreaLayoutGuide.topAnchor, AppLayout.mediumSpacing.value)

        tabBar
            .top(titleLabel.bottomAnchor, AppLayout.spacing.value).0
            .leading(view.leadingAnchor, padding).0
            .trailing(view.trailingAnchor, -padding)

        columnHeader
            .top(tabBar.bottomAnchor, AppLayout.smallSpacing.value).0
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
    }

    private func bindViewModel() {
        tabBar.onSelect = { [weak self] index in
            self?.viewModel.select(ExploreTab.allCases[index])
        }
        viewModel.onChange = { [weak self] in
            self?.reload()
        }
        viewModel.onFailed = { [weak self] message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    private func reload() {
        updateColumnHeader()
        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        })
        // Yeni tab həmişə yuxarıdan başlasın.
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.adjustedContentInset.top), animated: false)
    }

    /// Sıralama tab-larında "# CLUB PTS" başlığı görünür, Leagues tab-ında yox olur.
    private func updateColumnHeader() {
        if let columnTitle = viewModel.selectedTab.columnTitle {
            columnHeader.configure(columnTitle: columnTitle)
            columnHeader.isHidden = false
            columnHeaderHeight?.constant = Metrics.columnHeaderHeight
        } else {
            columnHeader.isHidden = true
            columnHeaderHeight?.constant = 0
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
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
        // Yalnız liqalara toxunmaq mümkündür; sıralama sətirləri məlumat üçündür.
        guard viewModel.selectedTab == .leagues else { return }
        coordinator?.showLeagueDetail(for: viewModel.leagues[indexPath.row])
    }
}

extension ExploreViewController: HidesNavigationBar {}
