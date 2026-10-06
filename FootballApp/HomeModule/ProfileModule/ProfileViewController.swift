//
//  ProfileViewController.swift
//  FootballApp
//

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

    init(profile: ProfileInfo) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Metrics

    private enum Metrics {
        static let avatarSize: CGFloat = 124
        static let editBadgeSize: CGFloat = 36
        static let tabHeight: CGFloat = 56
        static let logoutHeight: CGFloat = 56
    }

    private enum Palette {
        static let secondaryText = UIColor.white.withAlphaComponent(0.7)
        static let gradientStart = UIColor(red: 0.95, green: 0.62, blue: 0.50, alpha: 1)
        static let gradientEnd = UIColor(red: 0.88, green: 0.41, blue: 0.30, alpha: 1)
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
        config.baseBackgroundColor = Palette.gradientStart
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

    private let tabTitles = ["My Profile", "Activity", "Settings"]

    private lazy var tabButtons: [ProfileTabButton] = tabTitles.enumerated().map { index, title in
        let button = ProfileTabButton(title: title)
        button.isSelectedTab = index == 0
        button.addAction(UIAction { [weak self] _ in self?.selectTab(at: index) }, for: .touchUpInside)
        return button
    }

    private lazy var tabsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: tabButtons)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    private lazy var nameRow = ProfileInfoRow(icon: "person", title: "Name", value: profile.name)
    private lazy var emailRow = ProfileInfoRow(icon: "envelope", title: "Email", value: profile.email, underlined: true)
    private lazy var phoneRow = ProfileInfoRow(icon: "phone", title: "Phone Number", value: profile.phone)
    private lazy var addressRow = ProfileInfoRow(icon: "mappin.and.ellipse", title: "Address", value: profile.address)

    private lazy var infoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameRow, emailRow,phoneRow,addressRow])
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
            var c = container
            c.font = AppFonts.semiBold.font
            return c
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
    }

    // MARK: - Setup

    private func setupHierarchy() {
        contentView.addSubviews(
            avatarImageView,
            editBadgeButton,
            nameLabel,
            bioLabel,
            tabsStack,
            infoStack
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

        tabsStack
            .top(bioLabel.bottomAnchor, AppLayout.mediumSpacing.value).0
            .leading(contentView.leadingAnchor, padding).0
            .trailing(contentView.trailingAnchor, -padding).0
            .height(Metrics.tabHeight)

        infoStack
            .top(tabsStack.bottomAnchor, AppLayout.spacing.value).0
            .leading(contentView.leadingAnchor, padding).0
            .trailing(contentView.trailingAnchor, -padding).0
            .bottom(contentView.bottomAnchor)
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

    @objc private func editTapped() {
        coordinator?.showEditProfile()
    }

    private func selectTab(at index: Int) {
        tabButtons.enumerated().forEach { $1.isSelectedTab = $0 == index }
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

// MARK: - Tab pill

private final class ProfileTabButton: UIButton {

    var isSelectedTab = false {
        didSet { updateAppearance() }
    }

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.95, green: 0.62, blue: 0.50, alpha: 1).cgColor,
            UIColor(red: 0.88, green: 0.41, blue: 0.30, alpha: 1).cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    init(title: String) {
        super.init(frame: .zero)
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var c = container
            c.font = AppFonts.body.font.withWeight(.semibold)
            return c
        }
        configuration = config
        layer.insertSublayer(gradientLayer, at: 0)
        clipsToBounds = true
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        layer.cornerRadius = bounds.height / 2
    }

    private func updateAppearance() {
        gradientLayer.isHidden = !isSelectedTab
    }
}

private extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        UIFont.systemFont(ofSize: pointSize, weight: weight)
    }
}

// MARK: - Info row

private final class ProfileInfoRow: UIView {

    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = AssetColors.backgroundColor2.color
        view.layer.cornerRadius = 22
        return view
    }()

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.semiBold.font
        label.textColor = .white
        return label
    }()

    private let valueLabel = UILabel()

    private let chevronView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return view
    }()

    private let underlined: Bool

    init(icon: String, title: String, value: String, underlined: Bool = false) {
        self.underlined = underlined
        super.init(frame: .zero)
        iconView.image = UIImage(systemName: icon)
        titleLabel.text = title
        setValue(value)

        setupHierarchy()
        setupLayout()
    }

    func setValue(_ value: String) {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: AppFonts.regularBody.font.withWeight(.medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.7)
        ]
        if underlined { attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue }
        valueLabel.attributedText = NSAttributedString(string: value, attributes: attributes)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHierarchy() {
        iconContainer.addSubviews(iconView)
        addSubviews(iconContainer, titleLabel, valueLabel, chevronView, divider)
    }

    private func setupLayout() {
        iconContainer
            .leading(leadingAnchor).0
            .top(topAnchor, 14).0
            .width(44).0
            .height(44)

        iconView
            .centerX(iconContainer.centerXAnchor).0
            .centerY(iconContainer.centerYAnchor).0
            .width(20).0
            .height(20)

        titleLabel
            .top(topAnchor, 14).0
            .leading(iconContainer.trailingAnchor, 20)

        valueLabel
            .top(titleLabel.bottomAnchor, 6).0
            .leading(titleLabel.leadingAnchor)

        chevronView
            .trailing(trailingAnchor).0
            .centerY(iconContainer.centerYAnchor).0
            .width(14).0
            .height(18)

        divider
            .top(valueLabel.bottomAnchor, 16).0
            .leading(titleLabel.leadingAnchor).0
            .trailing(trailingAnchor, -44).0
            .bottom(bottomAnchor).0
            .height(1)
    }
}
