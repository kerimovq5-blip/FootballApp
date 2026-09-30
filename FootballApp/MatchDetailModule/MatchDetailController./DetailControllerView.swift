//
//  DetailControllerView.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 30.09.26.
//

import UIKit


final class MatchDetailController: UIViewController {

    private let data: MatchDetailData

    init(data: MatchDetailData) {
        self.data = data
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
        view.backgroundColor = UIColor(named: "mbappeback")
        configureNavbar()
        setupHierarchy()
        setupLayout()
        configureContent()
        showTab(.matchDetail)

        segmentControl.onTabSelected = { [weak self] tab in
            self?.showTab(tab)
        }
    }

    private func configureNavbar() {
        navigationItem.title = data.competitionName
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
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

    private func configureContent() {
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
    }

    private func showTab(_ tab: MatchDetailsTab) {
        statsView.isHidden = tab != .matchDetail
        lineUpView.isHidden = tab != .lineUp
        h2hView.isHidden = tab != .h2h
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
