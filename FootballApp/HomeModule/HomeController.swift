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
    
    private enum Section {
        case banner
    }
    
    private enum Metrics {
        static let iconSize: CGFloat = 28
    }
    
    private let sections: [Section] = [.banner]
    
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
    private lazy var headLabel: UILabel = {
        let label = UILabel()
        label.text = "QSscore"
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .white
        return label
    }()
    private lazy var notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "notificationicon")?.withRenderingMode(.alwaysOriginal), for: .normal)
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
        cv.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.reuseID)
        return cv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "mbappeback")
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
            }
        }
    }
    
    private func bannerSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        ))
        item.contentInsets = .init(top: 0, leading: AppLayout.screenPadding.value,
                                   bottom: 0, trailing: AppLayout.screenPadding.value)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(0.5)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16, leading: 0, bottom: 24, trailing: 0)
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
}

extension HomeController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .banner: return banners.count
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
        }
    }
}
