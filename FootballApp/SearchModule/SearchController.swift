//
//  SearchController.swift
//  FootballApp
//
//  Created by Servan on 28.09.26.
//

import UIKit

final class SearchController: UIViewController {

    weak var coordinator: HomeNavigating?

    private let viewModel: SearchViewModel
    private let subscriptions: MatchSubscriptionStoring
    private var didFocusSearchField = false

    init(viewModel: SearchViewModel,
         subscriptions: MatchSubscriptionStoring = UserDefaultsMatchSubscriptionStore.shared) {
        self.viewModel = viewModel
        self.subscriptions = subscriptions
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

    private lazy var searchField: UITextField = {
        let field = UITextField()
        field.font = AppFonts.body.font
        field.textColor = .white
        field.tintColor = AppGradient.accentEnd
        field.attributedPlaceholder = NSAttributedString(
            string: "Search teams or leagues",
            attributes: [
                .font: AppFonts.body.font,
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]
        )
        field.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        field.layer.cornerRadius = 14
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .search
        field.enablesReturnKeyAutomatically = true
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.keyboardAppearance = .dark
        field.delegate = self

        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = UIColor.white.withAlphaComponent(0.5)
        icon.contentMode = .center
        icon.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        field.leftView = icon
        field.leftViewMode = .always

        field.addAction(UIAction { [weak self] _ in
            self?.queryChanged()
        }, for: .editingChanged)
        return field
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.keyboardDismissMode = .onDrag
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SearchRowCell.self, forCellWithReuseIdentifier: SearchRowCell.reuseID)
        collectionView.register(MatchCell.self, forCellWithReuseIdentifier: MatchCell.reuseID)
        collectionView.register(SearchSectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SearchSectionHeaderView.reuseID)
        collectionView.register(LeagueHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: LeagueHeaderView.reuseID)
        return collectionView
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.regularBody.font
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var messageStack: UIStackView = {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass", withConfiguration: config))
        icon.tintColor = UIColor.white.withAlphaComponent(0.35)
        icon.contentMode = .scaleAspectFit

        let stack = UIStackView(arrangedSubviews: [icon, messageLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AssetColors.backgroundColor2.color
        setupLayout()
        bindViewModel()
        viewModel.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Klaviatura yalnız ilk açılışda çıxsın; detaldan qayıdanda yenidən açılmasın.
        guard !didFocusSearchField else { return }
        didFocusSearchField = true
        searchField.becomeFirstResponder()
    }

    // MARK: - Setup

    private func setupLayout() {
        let padding = AppLayout.screenPadding.value
        view.addSubviews(backButton, searchField, collectionView, messageStack)

        searchField
            .top(view.safeAreaLayoutGuide.topAnchor, AppLayout.smallSpacing.value).0
            .leading(backButton.trailingAnchor, AppLayout.smallSpacing.value).0
            .trailing(view.trailingAnchor, -padding).0
            .height(44)

        backButton
            .leading(view.leadingAnchor, padding).0
            .centerY(searchField.centerYAnchor).0
            .width(32).0
            .height(32)

        collectionView
            .top(searchField.bottomAnchor, AppLayout.spacing.value).0
            .leading(view.leadingAnchor).0
            .trailing(view.trailingAnchor).0
            .bottom(view.keyboardLayoutGuide.topAnchor)

        messageStack
            .top(searchField.bottomAnchor, 80).0
            .leading(view.leadingAnchor, 40).0
            .trailing(view.trailingAnchor, -40)
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] in
            self?.render()
        }
        viewModel.onFailed = { [weak self] message in
            self?.showAlert(message: message)
        }
    }

    private func render() {
        let message = viewModel.placeholderMessage
        messageLabel.text = message
        messageStack.isHidden = message == nil
        collectionView.isHidden = message != nil
        collectionView.reloadData()
        // Yeni nəticələr həmişə yuxarıdan başlasın.
        collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.adjustedContentInset.top),
                                        animated: false)
    }

    /// Bütün bölmələr Home-dakı liqa bölməsi ilə eyni görünüşdədir.
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let padding = AppLayout.screenPadding.value
        return UICollectionViewCompositionalLayout { _, _ in
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(64))
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10
            section.contentInsets = .init(top: 0, leading: padding, bottom: 20, trailing: padding)

            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            return section
        }
    }

    // MARK: - Actions

    private func queryChanged() {
        viewModel.updateQuery(searchField.text ?? "")
    }

    private func openLeague(_ league: League) {
        view.endEditing(true)
        viewModel.commitQuery()
        coordinator?.showLeagueDetail(for: league)
    }

    @objc private func backTapped() {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension SearchController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.commitQuery()
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.updateQuery("")
        return true
    }
}

// MARK: - UICollectionViewDataSource

extension SearchController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems(in: section)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.sections[indexPath.section] {
        case .recent:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SearchRowCell.reuseID, for: indexPath
            ) as? SearchRowCell else { return UICollectionViewCell() }
            cell.configure(icon: .symbol("clock.arrow.circlepath"),
                           title: viewModel.recentSearches[indexPath.item],
                           subtitle: nil,
                           accessorySymbol: "arrow.up.left")
            return cell

        case .leagues:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SearchRowCell.reuseID, for: indexPath
            ) as? SearchRowCell else { return UICollectionViewCell() }
            let league = viewModel.leagueResults[indexPath.item]
            cell.configure(icon: .emoji(league.flag),
                           title: league.name,
                           subtitle: league.country,
                           accessorySymbol: "chevron.right")
            return cell

        case .matches:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MatchCell.reuseID, for: indexPath
            ) as? MatchCell,
                  let match = viewModel.match(at: indexPath) else { return UICollectionViewCell() }
            cell.configure(with: match, isSubscribed: subscriptions.isSubscribed(match.id))
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
        switch viewModel.sections[indexPath.section] {
        case .recent:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: SearchSectionHeaderView.reuseID, for: indexPath
            ) as? SearchSectionHeaderView else { return UICollectionReusableView() }
            header.configure(title: "Recent searches", actionTitle: "Clear")
            header.onAction = { [weak self] in
                self?.viewModel.clearRecents()
            }
            return header

        case .leagues:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: SearchSectionHeaderView.reuseID, for: indexPath
            ) as? SearchSectionHeaderView else { return UICollectionReusableView() }
            header.configure(title: "Leagues", actionTitle: nil)
            return header

        case .matches:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: LeagueHeaderView.reuseID, for: indexPath
            ) as? LeagueHeaderView,
                  let league = viewModel.league(forMatchSection: indexPath.section)
            else { return UICollectionReusableView() }
            header.configure(with: league)
            header.onTap = { [weak self] in
                self?.openLeague(league)
            }
            return header
        }
    }
}

// MARK: - UICollectionViewDelegate

extension SearchController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch viewModel.sections[indexPath.section] {
        case .recent:
            let query = viewModel.recentSearches[indexPath.item]
            searchField.text = query
            viewModel.updateQuery(query)
            viewModel.commitQuery()

        case .leagues:
            openLeague(viewModel.leagueResults[indexPath.item])

        case .matches:
            guard let match = viewModel.match(at: indexPath) else { return }
            view.endEditing(true)
            viewModel.commitQuery()
            coordinator?.showMatchDetail(matchID: match.id)
        }
    }
}

extension SearchController: HidesNavigationBar {}
