//
//  NotificationsController.swift
//  FootballApp
//
//  Created by Servan on 28.09.26.
//

import UIKit

/// Bildirişi açılmış oyunlar Home-dakı kimi (liqalara görə, hesabla) göstərilir.
/// Təfərrüatları görmək üçün oyuna toxunmaq kifayətdir.
final class NotificationsController: UIViewController {

    weak var coordinator: HomeNavigating?

    private let viewModel: NotificationsViewModel

    init(viewModel: NotificationsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Notifications"
        label.font = AppFonts.semiBold.font
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { [weak self] _, _ in
            self?.leagueSection()
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset.bottom = 24
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MatchCell.self, forCellWithReuseIdentifier: MatchCell.reuseID)
        collectionView.register(LeagueHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: LeagueHeaderView.reuseID)
        return collectionView
    }()

    private lazy var emptyStack: UIStackView = {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let icon = UIImageView(image: UIImage(systemName: "bell", withConfiguration: symbolConfig))
        icon.tintColor = UIColor.white.withAlphaComponent(0.35)
        icon.contentMode = .scaleAspectFit

        let label = UILabel()
        label.font = AppFonts.regularBody.font
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "No matches yet.\nTap the bell next to a match to follow it and see it here."

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AssetColors.background.color
        setupLayout()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    // MARK: - Setup

    private func bindViewModel() {
        viewModel.onChange = { [weak self] in
            self?.render()
        }
        viewModel.onFailed = { [weak self] message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    private func setupLayout() {
        view.addSubviews(backButton, titleLabel, collectionView, emptyStack)

        backButton
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .top(view.safeAreaLayoutGuide.topAnchor, AppLayout.smallSpacing.value).0
            .width(32).0
            .height(32)

        titleLabel
            .centerX(view.centerXAnchor).0
            .centerY(backButton.centerYAnchor)

        collectionView
            .top(backButton.bottomAnchor, AppLayout.spacing.value).0
            .leading(view.leadingAnchor).0
            .trailing(view.trailingAnchor).0
            .bottom(view.bottomAnchor)

        emptyStack
            .centerX(view.centerXAnchor).0
            .centerY(view.centerYAnchor).0
            .leading(view.leadingAnchor, 40).0
            .trailing(view.trailingAnchor, -40)
    }

    private func render() {
        let isEmpty = viewModel.leagues.isEmpty
        collectionView.isHidden = isEmpty
        emptyStack.isHidden = !isEmpty
        collectionView.reloadData()
    }

    /// Home-dakı liqa bölməsi ilə eyni görünüş.
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
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        return section
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension NotificationsController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.leagues.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.leagues[section].matches.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MatchCell.reuseID, for: indexPath
        ) as? MatchCell,
              let match = viewModel.match(at: indexPath) else { return UICollectionViewCell() }

        // Bu ekranda bütün oyunların bildirişi açıqdır; zəngə basanda oyun siyahıdan çıxır.
        cell.configure(with: match, isSubscribed: true)
        cell.onBellTapped = { [weak self, weak cell] in
            cell?.setSubscribed(false, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.viewModel.unsubscribe(matchID: match.id)
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: LeagueHeaderView.reuseID, for: indexPath
        ) as? LeagueHeaderView else { return UICollectionReusableView() }

        let league = viewModel.leagues[indexPath.section]
        header.configure(with: league)
        header.onTap = { [weak self] in
            self?.coordinator?.showLeagueDetail(for: league)
        }
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension NotificationsController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let match = viewModel.match(at: indexPath) else { return }
        coordinator?.showMatchDetail(matchID: match.id)
    }
}

extension NotificationsController: HidesNavigationBar {}
