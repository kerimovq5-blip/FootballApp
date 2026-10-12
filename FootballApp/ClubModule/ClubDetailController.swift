//
//  ClubDetailController.swift
//  FootballApp
//
//  Created by Servan on 11.10.26.
//


//
//  ClubDetailController.swift
//  FootballApp
//

import UIKit

final class ClubDetailController: UIViewController {

    weak var coordinator: ClubNavigating?

    private let viewModel: ClubDetailViewModel

    init(viewModel: ClubDetailViewModel) {
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

    private let crestView = ClubCrestView(size: 72, inset: 12)

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.regularBody.font
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        return label
    }()

    private lazy var headerStack: UIStackView = {
        let textStack = UIStackView(arrangedSubviews: [nameLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let stack = UIStackView(arrangedSubviews: [crestView, textStack])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()

    private lazy var tabBar = PillTabBar(titles: ClubTab.allCases.map { $0.title }, alignment: .leading)

    private let contentContainer = UIView()
    private var clubName = ""
    private let overviewView = ClubOverviewView()
    private let matchesView = ClubMatchesView()
    private let standingView = ClubStandingView()
    private let squadView = ClubSquadView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AssetColors.background.color
        setupLayout()

        let club = viewModel.club
        configureHeader(name: club.name, country: club.country, flag: club.flag)

        // Data gələnə qədər boş tab-lar görünməsin.
        contentContainer.isHidden = true
        showTab(.overview)

        tabBar.onSelect = { [weak self] index in
            self?.showTab(ClubTab.allCases[index])
        }
        matchesView.onSelectMatch = { [weak self] matchID in
            self?.coordinator?.showMatchDetail(matchID: matchID)
        }
        standingView.onSelectClub = { [weak self] name in
            self?.coordinator?.showClubDetail(for: ClubReference(name: name))
        }
        clubName = viewModel.club.name
        squadView.onSelectPlayer = { [weak self] player in
            guard let self else { return }
            self.coordinator?.showPlayerDetail(for: PlayerReference(name: player.name,
                                                                    clubName: self.clubName,
                                                                    number: player.number))
        }
        bindViewModel()
        viewModel.load()
    }

    // MARK: - Setup

    private func setupLayout() {
        let padding = AppLayout.screenPadding.value
        view.addSubviews(backButton, headerStack, tabBar, contentContainer)
        contentContainer.addSubviews(overviewView, matchesView, standingView, squadView)

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

        [overviewView, matchesView, standingView, squadView].forEach { pin($0, to: contentContainer) }
    }

    private func pin(_ child: UIView, to parent: UIView) {
        child
            .top(parent.topAnchor).0
            .leading(parent.leadingAnchor).0
            .trailing(parent.trailingAnchor).0
            .bottom(parent.bottomAnchor)
    }

    private func bindViewModel() {
        viewModel.onLoaded = { [weak self] content in
            self?.apply(content)
        }
        viewModel.onFailed = { [weak self] message in
            self?.showAlert(message: message)
        }
    }

    private func configureHeader(name: String, country: String?, flag: String?) {
        nameLabel.text = name
        crestView.configure(initials: name)
        subtitleLabel.text = [flag, country].compactMap { $0 }.joined(separator: " ")
    }

    private func apply(_ content: ClubDetailContent) {
        let profile = content.profile
        clubName = profile.name
        configureHeader(name: profile.name, country: profile.country, flag: profile.flag)

        overviewView.configure(with: content)
        matchesView.configure(with: content)
        standingView.configure(with: content)
        squadView.configure(with: content)
        contentContainer.isHidden = false
        showTab(ClubTab.allCases[tabBar.selectedIndex])
    }

    private func showTab(_ tab: ClubTab) {
        overviewView.isHidden = tab != .overview
        matchesView.isHidden = tab != .matches
        standingView.isHidden = tab != .standing
        squadView.isHidden = tab != .squad
        
        if tab == .standing {
            standingView.revealClub()
        }
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension ClubDetailController: HidesNavigationBar {}
