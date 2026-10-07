//
//  DetailControllerView.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 30.09.26.
//

import UIKit


final class MatchDetailController: UIViewController {

    private let viewModel: MatchDetailViewModel

    init(viewModel: MatchDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var headerView = MatchHeaderView()
    private lazy var segmentControl = MatchDetailSegmentControl()
    private lazy var statsView = MatchStatsView()
    private lazy var lineUpView = LineUpView()
    private lazy var h2hView = H2HView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundColor2")
        navigationItem.backButtonDisplayMode = .minimal
        setupHierarchy()
        setupLayout()

        // Data gələnə qədər boş ekran görünməsin.
        [headerView, segmentControl, statsView, lineUpView, h2hView].forEach { $0.isHidden = true }

        segmentControl.onTabSelected = { [weak self] tab in
            self?.showTab(tab)
        }
        bindViewModel()
        viewModel.load()
    }

    private func bindViewModel() {
        viewModel.onLoaded = { [weak self] data in
            self?.apply(data)
        }
        viewModel.onFailed = { [weak self] message in
            self?.showError(message)
        }
    }

    private func apply(_ data: MatchDetailData) {
        navigationItem.title = data.competitionName
        headerView.configure(
            homeName: data.homeName,
            awayName: data.awayName,
            homeCrest: data.homeCrest,
            awayCrest: data.awayCrest,
            score: data.score,
            minuteOrStatus: data.minuteOrStatus
        )
        statsView.configure(with: data.stats)
        lineUpView.configure(formationName: data.formationName, formation: data.formation)
        h2hView.configure(with: data.headToHead)

        headerView.isHidden = false
        segmentControl.isHidden = false
        showTab(.matchDetail)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setupHierarchy() {
        view.addSubviews(headerView, segmentControl, statsView, lineUpView, h2hView)
    }

    private func setupLayout() {
        headerView
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .top(view.safeAreaLayoutGuide.topAnchor, AppLayout.spacing.value)

        segmentControl
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .top(headerView.bottomAnchor, AppLayout.mediumSpacing.value).0
            .height(44)

        [statsView, lineUpView, h2hView].forEach { contentView in
            contentView
                .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
                .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
                .top(segmentControl.bottomAnchor, AppLayout.mediumSpacing.value)
        }
    }

    private func showTab(_ tab: MatchDetailsTab) {
        statsView.isHidden = tab != .matchDetail
        lineUpView.isHidden = tab != .lineUp
        h2hView.isHidden = tab != .h2h
    }
}
