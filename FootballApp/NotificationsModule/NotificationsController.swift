//
//  NotificationsController.swift
//  FootballApp
//
//  Created by Servan on 28.09.26.
//

import UIKit

/// Yalnız bildirişi açılmış (Home-da zəng düyməsinə basılmış) oyunların bildirişləri, oyunlara görə qruplaşdırılmış.
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

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderTopPadding = 0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 60
        tableView.contentInset.bottom = 24
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseID)
        tableView.register(NotificationGroupHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: NotificationGroupHeaderView.reuseID)
        return tableView
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
        label.text = "No notifications yet.\nTap the bell next to a match to get its updates here."

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
        viewModel.onChange = { [weak self] in
            self?.render()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubviews(backButton, titleLabel, tableView, emptyStack)

        backButton
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .top(view.safeAreaLayoutGuide.topAnchor, AppLayout.smallSpacing.value).0
            .width(32).0
            .height(32)

        titleLabel
            .centerX(view.centerXAnchor).0
            .centerY(backButton.centerYAnchor)

        tableView
            .top(backButton.bottomAnchor, AppLayout.smallSpacing.value).0
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
        let isEmpty = viewModel.groups.isEmpty
        tableView.isHidden = isEmpty
        emptyStack.isHidden = !isEmpty
        tableView.reloadData()
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension NotificationsController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.groups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.groups[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationCell.reuseID, for: indexPath
        ) as? NotificationCell else { return UITableViewCell() }

        cell.configure(with: viewModel.groups[indexPath.section].items[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotificationsController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: NotificationGroupHeaderView.reuseID
        ) as? NotificationGroupHeaderView else { return nil }

        let group = viewModel.groups[section]
        header.configure(title: group.matchTitle, subtitle: group.competition)
        return header
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.groups[indexPath.section].items[indexPath.row]
        coordinator?.showMatchDetail(matchID: item.matchID)
    }
}

extension NotificationsController: HidesNavigationBar {}
