//
//  HomeController.swift
//  FootballApp
//
//  Created by Servan on 27.09.26.
//

import UIKit

final class HomeController: UIViewController {
    var onSearchTapped: (() -> Void)?
    var onNotificationTapped: (() -> Void)?
    var onMatchTapped: ((Match) -> Void)?
    
    private enum Section {
        case banner
        case filter
        case league(index: Int)
    }
    
    private var selectedFilter: MatchFilter = .all {
        didSet { collectionView.reloadData() }
    }
    
    private var filteredLeagues: [League] {
        switch selectedFilter {
        case .all:
            return leagues
        case .live:
            return leagues.compactMap{ leauge in
                let liveMatches = leauge.matches.filter{$0.status.isLive}
                    guard !liveMatches.isEmpty else { return nil }
                return League(name: leauge.name, country: leauge.country, flag: leauge.flag, matches: liveMatches)
                
            }
        }
        
    }
    
    private var sections: [Section] {
        [.banner, .filter] + filteredLeagues.indices.map{Section.league(index: $0)} }
    
    private let banners = [Banner(
        categoryTitle: "Football",
        title: "Fransa defeated Turkey",
        dateText: "Yesterday, 06.30 PM",
        image: UIImage(named: "trophyCelebration")
    ),.init(
        categoryTitle: "Football",
        title: "Besiktas Win 5-0 Over Galatasaray",
        dateText: "3 August 2024",
        image: UIImage(named: "besiktaswin")
    )]
    private let leagues: [League] = [
            League(name: "La Liga", country: "Spain", flag: "🇪🇸", matches: [
                Match(home: "Barcelona", away: "Real Madrid", homeScore: 1, awayScore: 2, status: .live(minute: "63'")),
                Match(home: "Sevilla", away: "Valencia", homeScore: nil, awayScore: nil, status: .scheduled(kickoff: "22:00"))
            ]),
            League(name: "Premier League", country: "England", flag: "🏴󠁧󠁢󠁥󠁮󠁧󠁿", matches: [
                Match(home: "Aston Villa", away: "Liverpool", homeScore: 2, awayScore: 3, status: .finished)
            ]),
            League(name: "Trendyol Süper Lig", country: "Turkey", flag: "🇹🇷", matches: [Match(home: "Besiktas", away: "Fenerbahce", homeScore: 3, awayScore: 1, status: .live(minute: "21'")),Match(home: "Trabzonspor", away: "Galatasaray", homeScore: 0, awayScore: 1, status: .live(minute: "21'"))]
    )]
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

    @objc private func searchTapped() { onSearchTapped?() }
    @objc private func notificationTapped() { onNotificationTapped?() }
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
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self else { return nil }
            switch self.sections[sectionIndex] {
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
        guard case .league(let index) = sections[indexPath.section] else { return }
        let match = filteredLeagues[index].matches[indexPath.item]
        onMatchTapped?(match)
    }
}

extension HomeController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .banner: return banners.count
        case .filter: return 1
        case .league(let index): return filteredLeagues[index].matches.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .banner:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BannerCell.reuseID, for: indexPath
            ) as? BannerCell else { return UICollectionViewCell() }
            cell.configure(with: banners[indexPath.item])
            return cell
        case .filter:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MatchFilterCell.reuseID, for: indexPath) as? MatchFilterCell
                    else { return UICollectionViewCell() }
                    cell.configure(selected: selectedFilter)
                    cell.onFilterChanged = { [weak self] filter in
                        self?.selectedFilter = filter
                    }
                    return cell

        
        case .league(let index):
            guard let cell = collectionView.dequeueReusableCell(
                            withReuseIdentifier: MatchCell.reuseID, for: indexPath) as? MatchCell
                        else { return UICollectionViewCell() }
                        cell.configure(with: filteredLeagues[index].matches[indexPath.item])
                        return cell
        }
        
        }
    func collectionView(_ collectionView: UICollectionView,
                            viewForSupplementaryElementOfKind kind: String,
                            at indexPath: IndexPath) -> UICollectionReusableView {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: LeagueHeaderView.reuseID, for: indexPath
            ) as? LeagueHeaderView else { return UICollectionReusableView() }

            if case .league(let index) = sections[indexPath.section] {
                header.configure(with: filteredLeagues[index])
            }
            return header
        }
    }

