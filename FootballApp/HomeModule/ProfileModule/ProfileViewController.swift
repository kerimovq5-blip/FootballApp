import UIKit

struct ProfileInfo {
    var name: String
    let email: String
    var bio: String
    var avatar: UIImage?
    var phone: String
    var address: String
}

final class ProfileViewController: UIViewController {

    weak var coordinator: ProfileNavigating?

    private var profile: ProfileInfo
    private let activityStore: ActivityStoring
    private let settings: SettingsStoring

    init(profile: ProfileInfo, activityStore: ActivityStoring, settings: SettingsStoring) {
        self.profile = profile
        self.activityStore = activityStore
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Types

    private enum Section: Int, CaseIterable {
        case profile
        case activity
        case settings

        var title: String {
            switch self {
            case .profile: return "My Profile"
            case .activity: return "Activity"
            case .settings: return "Settings"
            }
        }
    }

    private enum Metrics {
        static let avatarSize: CGFloat = 124
        static let editBadgeSize: CGFloat = 36
        static let logoutHeight: CGFloat = 56
    }

    private enum Palette {
        static let secondaryText = UIColor.white.withAlphaComponent(0.7)
    }

    // MARK: - Views

    private lazy var avatarImageView: AvatarImageView = {
        let imageView = AvatarImageView(size: Metrics.avatarSize)
        imageView.setAvatar(profile.avatar)
        return imageView
    }()

    private lazy var editBadgeButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "pencil")
        config.baseBackgroundColor = AppGradient.accentStart
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        let button = UIButton(configuration: config)
        button.layer.borderWidth = 3
        button.layer.borderColor = AssetColors.background.color.cgColor
        button.layer.cornerRadius = Metrics.editBadgeSize / 2
        button.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        return button
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = profile.name
        label.font = AppFonts.titleBold.font
        label.textColor = .titleColor
        label.textAlignment = .center
        return label
    }()

    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.text = profile.bio
        label.font = AppFonts.regularBody.font
        label.textColor = Palette.secondaryText
        label.textAlignment = .center
        return label
    }()

    private lazy var tabBar = PillTabBar(
        titles: Section.allCases.map { $0.title },
        alignment: .spread
    )

    // My Profile
    private lazy var nameRow = ProfileInfoRow(icon: "person", title: "Name", value: profile.name, accessory: .chevron)
    private lazy var emailRow = ProfileInfoRow(icon: "envelope", title: "Email", value: profile.email, underlined: true)
    private lazy var phoneRow = ProfileInfoRow(icon: "phone", title: "Phone Number", value: profile.phone, accessory: .chevron)
    private lazy var addressRow = ProfileInfoRow(icon: "mappin.and.ellipse", title: "Address", value: profile.address, accessory: .chevron)

    private lazy var infoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameRow, emailRow, phoneRow, addressRow])
        stack.axis = .vertical
        return stack
    }()

    // Activity və Settings
    private lazy var activityView = ProfileActivityView(store: activityStore)
    private lazy var settingsView = ProfileSettingsView(settings: settings)

    private lazy var sectionStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [infoStack, activityView, settingsView])
        stack.axis = .vertical
        return stack
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView = UIView()

    private lazy var logoutButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "Log out"
        config.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        config.imagePadding = 8
        config.baseForegroundColor = .systemRed
        config.baseBackgroundColor = .systemRed
        config.cornerStyle = .capsule
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var updated = container
            updated.font = AppFonts.semiBold.font
            return updated
        }
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AssetColors.background.color
        setupHierarchy()
        setupLayout()
        bindActions()
        showSection(at: Section.profile.rawValue)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Oyun detalından qayıdanda siyahı yenilənsin.
        if !activityView.isHidden {
            activityView.reload()
        }
    }

    // MARK: - Setup

    private func setupHierarchy() {
        contentView.addSubviews(
            avatarImageView,
            editBadgeButton,
            nameLabel,
            bioLabel,
            tabBar,
            sectionStack
        )
        scrollView.addSubviews(contentView)
        view.addSubviews(scrollView, logoutButton)
    }

    private func setupLayout() {
        let padding = AppLayout.screenPadding.value

        logoutButton
            .leading(view.leadingAnchor, padding).0
            .trailing(view.trailingAnchor, -padding).0
            .bottom(view.safeAreaLayoutGuide.bottomAnchor, -padding).0
            .height(Metrics.logoutHeight)

        scrollView
            .top(view.safeAreaLayoutGuide.topAnchor).0
            .leading(view.leadingAnchor).0
            .trailing(view.trailingAnchor).0
            .bottom(logoutButton.topAnchor, -AppLayout.spacing.value)

        contentView
            .top(scrollView.contentLayoutGuide.topAnchor).0
            .leading(scrollView.contentLayoutGuide.leadingAnchor).0
            .trailing(scrollView.contentLayoutGuide.trailingAnchor).0
            .bottom(scrollView.contentLayoutGuide.bottomAnchor).0
            .width(scrollView.frameLayoutGuide.widthAnchor)

        avatarImageView
            .top(contentView.topAnchor, AppLayout.spacing.value).0
            .centerX(contentView.centerXAnchor).0
            .width(Metrics.avatarSize).0
            .height(Metrics.avatarSize)

        editBadgeButton
            .trailing(avatarImageView.trailingAnchor).0
            .bottom(avatarImageView.bottomAnchor).0
            .width(Metrics.editBadgeSize).0
            .height(Metrics.editBadgeSize)

        nameLabel
            .top(avatarImageView.bottomAnchor, AppLayout.spacing.value).0
            .leading(contentView.leadingAnchor, padding).0
            .trailing(contentView.trailingAnchor, -padding)

        bioLabel
            .top(nameLabel.bottomAnchor, AppLayout.smallSpacing.value).0
            .leading(contentView.leadingAnchor, padding).0
            .trailing(contentView.trailingAnchor, -padding)

        tabBar
            .top(bioLabel.bottomAnchor, AppLayout.mediumSpacing.value).0
            .leading(contentView.leadingAnchor, padding).0
            .trailing(contentView.trailingAnchor, -padding)

        sectionStack
            .top(tabBar.bottomAnchor, AppLayout.spacing.value).0
            .leading(contentView.leadingAnchor, padding).0
            .trailing(contentView.trailingAnchor, -padding).0
            .bottom(contentView.bottomAnchor)
    }

    private func bindActions() {
        tabBar.onSelect = { [weak self] index in
            self?.showSection(at: index)
        }

        // Email dəyişdirilə bilmir, ona görə onun sətri toxunuşsuzdur.
        [nameRow, phoneRow, addressRow].forEach { row in
            row.onTap = { [weak self] in
                self?.coordinator?.showEditProfile()
            }
        }

        activityView.onSelectMatch = { [weak self] matchID in
            self?.coordinator?.showMatchDetail(matchID: matchID)
        }

        settingsView.onClearActivity = { [weak self] in
            self?.confirmClearActivity()
        }
    }

    // MARK: - Public

    /// Edit ekranında saxlanandan sonra coordinator çağırır.
    func update(_ profile: ProfileInfo) {
        self.profile = profile
        nameLabel.text = profile.name
        bioLabel.text = profile.bio
        avatarImageView.setAvatar(profile.avatar)
        nameRow.setValue(profile.name)
        phoneRow.setValue(profile.phone)
        addressRow.setValue(profile.address)
    }

    // MARK: - Actions

    private func showSection(at index: Int) {
        guard let section = Section(rawValue: index) else { return }
        infoStack.isHidden = section != .profile
        activityView.isHidden = section != .activity
        settingsView.isHidden = section != .settings

        if section == .activity {
            activityView.reload()
        }
    }

    @objc private func editTapped() {
        coordinator?.showEditProfile()
    }

    private func confirmClearActivity() {
        let alert = UIAlertController(
            title: "Clear activity",
            message: "Remove all recently viewed matches?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            self?.activityStore.clear()
            self?.activityView.reload()
        })
        present(alert, animated: true)
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Log out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log out", style: .destructive) { [weak self] _ in
            self?.coordinator?.logout()
        })
        present(alert, animated: true)
    }
}
