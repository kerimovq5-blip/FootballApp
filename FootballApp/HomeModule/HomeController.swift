//
//  HomeController.swift
//  FootballApp
//
//  Created by Servan on 27.09.26.
//

import UIKit

final class HomeController: UIViewController {
    
    weak var coordinator : HomeNavigating?
    private let viewModel: HomeViewModel
    private let subscriptions: MatchSubscriptionStoring

        init(viewModel: HomeViewModel,
             subscriptions: MatchSubscriptionStoring = UserDefaultsMatchSubscriptionStore.shared) {
            self.viewModel = viewModel
            self.subscriptions = subscriptions
            super.init(nibName: nil, bundle: nil)
        }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var headLabel: UILabel = {
        let label = UILabel()
        label.text = "QSscore"
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .white
        return label
    }()
    private lazy var notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "notificationicon")?.withRenderingMode(.alwaysOriginal),
                        for: .normal)
        button.addTarget(self, action: #selector(notificationTapped), for: .touchUpInside)
        return button
    }()

    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "searchicon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        return button
    }()

    
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.reuseID)
        cv.register(MatchCell.self, forCellWithReuseIdentifier: MatchCell.reuseID)
        cv.register(MatchFilterCell.self, forCellWithReuseIdentifier: MatchFilterCell.reuseID)
        cv.register(LeagueHeaderView.self,
                           forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                           withReuseIdentifier: LeagueHeaderView.reuseID)
        return cv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AssetColors.backgroundColor2.color
        setupLayout()
        bindViewModel()
        viewModel.load()
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] in
            self?.collectionView.reloadData()
        }
        viewModel.onFailed = { [weak self] message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    private func setupLayout() {
        view.addSubviews(headLabel,notificationButton,searchButton,collectionView)
        
        headLabel
            .leading(view.leadingAnchor,AppLayout.mediumSpacing.value).0
            .top(view.safeAreaLayoutGuide.topAnchor,AppLayout.mediumSpacing.value)
        notificationButton
            .trailing(view.trailingAnchor, -AppLayout.mediumSpacing.value).0
            .centerY(headLabel.centerYAnchor).0
            .height(30).0
            .width(30)
        searchButton
            .trailing(notificationButton.leadingAnchor, -AppLayout.mediumSpacing.value).0
            .centerY(headLabel.centerYAnchor).0
            .height(30).0
            .width(30)
        collectionView
            .top(headLabel.bottomAnchor, 12).0
            .leading(view.leadingAnchor).0
            .trailing(view.trailingAnchor).0
            .bottom(view.bottomAnchor)
    }
    
    
    @objc private func searchTapped() { coordinator?.showSearch() }
    @objc private func notificationTapped() { coordinator?.showNotifications() }
    
    
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self else { return nil }
            switch self.viewModel.sections[sectionIndex] {
            case .banner: return self.bannerSection()
            case .filter: return self.filterSection()
            case .league: return self.leagueSection()
            }
        }
    }
    
    private func bannerSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        ))
        item.contentInsets = .init(
            top: 0,
            leading: AppLayout.screenPadding.value,
            bottom: 0,
            trailing: AppLayout.screenPadding.value
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(0.5)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(
            top: 16,
            leading: 0,
            bottom: 24,
            trailing: 0
        )
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
    private func filterSection() -> NSCollectionLayoutSection {
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(
            top: 0,
            leading: AppLayout.screenPadding.value,
            bottom: 16,
            trailing: AppLayout.screenPadding.value
        )
            return section
        }

        private func leagueSection() -> NSCollectionLayoutSection {
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(64))
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10
            section.contentInsets = .init(
                top: 0,
                leading: AppLayout.screenPadding.value,
                bottom: 20,
                trailing: AppLayout.screenPadding.value
            )

            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(44)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            return section
        }
}

extension HomeController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let match = viewModel.match(at: indexPath) else { return }
        coordinator?.showMatchDetail(matchID: match.id)
    }
}

extension HomeController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewModel.sections[section] {
        case .banner: return viewModel.banners.count
        case .filter: return 1
        case .league: return viewModel.league(inSection: section)?.matches.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.sections[indexPath.section] {
        case .banner:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BannerCell.reuseID, for: indexPath
            ) as? BannerCell else { return UICollectionViewCell() }
            cell.configure(with: viewModel.banners[indexPath.item])
            return cell
        case .filter:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MatchFilterCell.reuseID, for: indexPath) as? MatchFilterCell
                    else { return UICollectionViewCell() }
                    cell.configure(selected: viewModel.selectedFilter)
                    cell.onFilterChanged = { [weak self] filter in
                        self?.viewModel.selectFilter(filter)
                    }
                    return cell

        
        case .league:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MatchCell.reuseID,
                for: indexPath
            ) as? MatchCell,
            let match = viewModel.match(at: indexPath)
            else { return UICollectionViewCell() }
            cell
                .configure(with: match, isSubscribed: subscriptions.isSubscribed(match.id))
                        cell.onBellTapped = { [weak self, weak cell] in
                            guard let self, let cell else { return }
                            let isSubscribed = self.subscriptions.toggle(match.id)
                            cell.setSubscribed(isSubscribed, animated: true)
                        }
                        return cell
        }
        
        }
    func collectionView(_ collectionView: UICollectionView,
                            viewForSupplementaryElementOfKind kind: String,
                            at indexPath: IndexPath) -> UICollectionReusableView {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: LeagueHeaderView.reuseID, for: indexPath
            ) as? LeagueHeaderView else { return UICollectionReusableView() }

            if let league = viewModel.league(inSection: indexPath.section) {
                    header.configure(with: league)
                header.onTap = { [weak self] in
                    self?.coordinator?.showLeagueDetail(for: league)
                    }
            }
            return header
        }
    }

extension HomeController: HidesNavigationBar {}
