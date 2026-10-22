//
//  PlayerDetailController.swift
//  FootballApp
//
//  Created by Servan on 12.10.26.
//

//
//  PlayerDetailController.swift
//  FootballApp
//

import UIKit

final class PlayerDetailController: UIViewController {

    weak var coordinator: ClubNavigating?

    private let viewModel: PlayerDetailViewModel

    init(viewModel: PlayerDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Views

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()

    private let avatarView = ClubCrestView(size: 72, inset: 12)

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private lazy var clubLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        return label
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = .regularBody
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        return label
    }()

    private lazy var headerStack: UIStackView = {
        let textStack = UIStackView(arrangedSubviews: [nameLabel, clubLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 3

        let stack = UIStackView(arrangedSubviews: [avatarView, textStack])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()

    private lazy var tabBar = PillTabBar(titles: PlayerTab.allCases.map { $0.title })

    private let contentContainer = UIView()
    private let overviewView = PlayerOverviewView()
    private let matchesView = PlayerMatchesView()
    private let statsView = PlayerStatsView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AssetColors.background.color
        setupLayout()

        let player = viewModel.player
        nameLabel.text = player.name
        clubLabel.text = player.clubName
        avatarView.configure(initials: PlayerDetailController.initials(for: player.name))

        contentContainer.isHidden = true
        showTab(.overview)

        tabBar.onSelect = { [weak self] index in
            self?.showTab(PlayerTab.allCases[index])
        }
        overviewView.onSelectClub = { [weak self] club in
            self?.coordinator?.showClubDetail(for: club)
        }
        matchesView.onSelectMatch = { [weak self] matchID in
            self?.coordinator?.showMatchDetail(matchID: matchID)
        }

        viewModel.onLoaded = { [weak self] content in
            self?.stateView.hide()
            self?.apply(content)
        }
        viewModel.onFailed = { [weak self] error in
            self?.stateView.show(error)
        }
        stateView.showLoading()
        viewModel.load()
    }

    /// Məzmunun yerində: yüklənir və ya xəta + "Try again".
    private lazy var stateView: StateView = {
        let stateView = StateView()
        stateView.onRetry = { [weak self] in
            self?.stateView.showLoading()
            self?.viewModel.load()
        }
        return stateView
    }()

    // MARK: - Setup

    private func setupLayout() {
        let padding = AppLayout.screenPadding.value
        view.addSubviews(backButton, headerStack, tabBar, contentContainer, stateView)
        stateView.pinEdges(to: contentContainer)
        contentContainer.addSubviews(overviewView, matchesView, statsView)

        backButton
            .leading(view.leadingAnchor, padding).0
            .top(view.safeAreaLayoutGuide.topAnchor, AppLayout.smallSpacing.value).0
            .width(32).0
            .height(32)

        headerStack
            .top(backButton.bottomAnchor, AppLayout.spacing.value).0
            .leading(view.leadingAnchor, padding).0
            .trailing(view.trailingAnchor, -padding)

        tabBar
            .top(headerStack.bottomAnchor, 20).0
            .leading(view.leadingAnchor, padding).0
            .trailing(view.trailingAnchor, -padding)

        contentContainer
            .top(tabBar.bottomAnchor, 16).0
            .leading(view.leadingAnchor).0
            .trailing(view.trailingAnchor).0
            .bottom(view.bottomAnchor)

        [overviewView, matchesView, statsView].forEach { pin($0, to: contentContainer) }
    }

    private func pin(_ child: UIView, to parent: UIView) {
        child
            .top(parent.topAnchor).0
            .leading(parent.leadingAnchor).0
            .trailing(parent.trailingAnchor).0
            .bottom(parent.bottomAnchor)
    }

    private func apply(_ content: PlayerDetailContent) {
        let profile = content.profile
        nameLabel.text = profile.name
        clubLabel.text = "\(profile.club.name) · #\(profile.number)"
        let origin = profile.nationality.isEmpty ? "" : "\(profile.flag) \(profile.nationality) · "
        detailLabel.text = origin + profile.position.singularTitle
        avatarView.configure(initials: PlayerDetailController.initials(for: profile.name))

        overviewView.configure(with: content)
        matchesView.configure(with: content)
        statsView.configure(with: content)

        contentContainer.isHidden = false
        showTab(PlayerTab.allCases[tabBar.selectedIndex])
    }

    private func showTab(_ tab: PlayerTab) {
        overviewView.isHidden = tab != .overview
        matchesView.isHidden = tab != .matches
        statsView.isHidden = tab != .statistics
    }

    private static func initials(for name: String) -> String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
            .uppercased()
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension PlayerDetailController: HidesNavigationBar {}
