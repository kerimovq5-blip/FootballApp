import UIKit

final class SignUpController: UIViewController {

    weak var coordinator : AuthNavigating?
    private let viewModel: SignUpViewModel

    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private enum Metrics {
        static let fieldHeight: CGFloat = 56
        static let buttonHeight: CGFloat = 63
        static let checkboxSize: CGFloat = 22
    }

    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Create account"
        label.textColor = .titleColor
        label.font = AppFonts.title.font
        label.textAlignment = .center
        return label
    }()

    private lazy var usernameField = AppTextField(
        placeholder: "Username",
        textColor: .labelColor,
        leftIcon: UIImage(named: "usericon")?.withRenderingMode(.alwaysTemplate)
    )

    private lazy var emailField = AppTextField(
        placeholder: "Email",
        textColor: .labelColor,
        leftIcon: UIImage(named: "emailicon")
    )

    private lazy var passwordField: AppTextField = {
        let toggleButton = makePasswordToggleButton(
            action: #selector(togglePasswordVisibility))
        let passwordField = AppTextField(
            placeholder: "Password",
            isSecure: true,
            textColor: .labelColor,
            leftIcon: UIImage(named: "passwordicon"),
            rightView: toggleButton)
        return passwordField
    }()

    private lazy var confirmPasswordField: AppTextField = {
        let toggleButton = makePasswordToggleButton(action: #selector(toggleConfirmPasswordVisibility))
        
        let confirmPasswordField = AppTextField(
            placeholder: "Confirm password",
            isSecure: true,
            textColor: .labelColor,
            leftIcon: UIImage(named: "passwordicon"),
            rightView: toggleButton
        )
        return confirmPasswordField
    }()

    private lazy var agreementLabel: UILabel = {
        let label = UILabel()
        let attributed = NSMutableAttributedString(
            string: "I have read the ",
            attributes: [
                .foregroundColor: AssetColors.labelColor.color,
                .font: AppFonts.semiBold.font
            ]
        )
        attributed.append(
            NSAttributedString(
                string: "Privacy Policy",
                attributes: [
                    .foregroundColor: UIColor.accent,
                    .font: AppFonts.semiBold.font
                ]
            )
        )
        label.attributedText = attributed
        label.numberOfLines = 0
        return label
    }()

    private lazy var agreementButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.labelColor.cgColor
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(toggleAgreement), for: .touchUpInside)
        return button
    }()

    private lazy var signUpButton: AppButton = {
        let button = AppButton(
            title: "Sign up",
            backgroundColor: .accent,
            titleColor: .titleColor
        )
        button.onTap = { [weak self] in
            self?.handleSignUpTapped()
        }
        return button
    }()

    private lazy var signInPromptButton: UIButton = {
        let button = UIButton(type: .system)
        let text = NSMutableAttributedString(
            string: "Already have an account? ",
            attributes: [
                .foregroundColor: AssetColors.labelColor.color,
                .font: AppFonts.regularBody.font
            ]
        )
        text.append(NSAttributedString(
            string: "Sign In",
            attributes: [
                .foregroundColor: UIColor.accent,
                .font: AppFonts.regularBody.font
            ]
        ))
        button.setAttributedTitle(text, for: .normal)
        button.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AssetColors.backgroundColor2.color
        configureNavbar()
        setupHierarchy()
        setupLayout()
        configureFields()
        bindViewModel()
    }

    private func configureFields() {
        emailField.textField.keyboardType = .emailAddress
        emailField.textField.autocapitalizationType = .none
        emailField.textField.autocorrectionType = .no
        usernameField.textField.autocapitalizationType = .none
        usernameField.textField.autocorrectionType = .no
        passwordField.textField.autocapitalizationType = .none
        confirmPasswordField.textField.autocapitalizationType = .none
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] in
            guard let self else { return }
            switch self.viewModel.state {
            case .idle, .success:
                self.signUpButton.setLoading(false)
            case .loading:
                self.signUpButton.setLoading(true)
            case .invalidInput(let message):
                self.signUpButton.setLoading(false)
                self.showAlert(message: message)
            case .requestFailed(let error):
                self.signUpButton.setLoading(false)
                self.showAlert(message: error.localizedDescription)
            }
        }
    }

    private func configureNavbar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
    }

    private func setupHierarchy() {
        view.addSubviews(
            welcomeLabel,
            usernameField,
            emailField,
            passwordField,
            confirmPasswordField,
            agreementLabel,
            agreementButton,
            signUpButton,
            signInPromptButton
        )
    }

    private func setupLayout() {
        welcomeLabel
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .top(view.safeAreaLayoutGuide.topAnchor, AppLayout.spacing.value)

        usernameField
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .top(welcomeLabel.bottomAnchor, AppLayout.largeSpacing.value).0
            .height(Metrics.fieldHeight)

        emailField
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .top(usernameField.bottomAnchor, AppLayout.mediumSpacing.value).0
            .height(Metrics.fieldHeight)

        passwordField
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .top(emailField.bottomAnchor, AppLayout.mediumSpacing.value).0
            .height(Metrics.fieldHeight)

        confirmPasswordField
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .top(passwordField.bottomAnchor, AppLayout.mediumSpacing.value).0
            .height(Metrics.fieldHeight)

        agreementLabel
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(agreementButton.leadingAnchor, -AppLayout.smallSpacing.value).0
            .top(confirmPasswordField.bottomAnchor, AppLayout.mediumSpacing.value)

        agreementButton
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .centerY(agreementLabel.centerYAnchor).0
            .width(Metrics.checkboxSize).0
            .height(Metrics.checkboxSize)

        signUpButton
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .top(agreementLabel.bottomAnchor, AppLayout.largeSpacing.value).0
            .height(Metrics.buttonHeight)

        signInPromptButton
            .centerX(view.centerXAnchor).0
            .top(signUpButton.bottomAnchor, AppLayout.mediumSpacing.value)
    }

    private func handleSignUpTapped() {
        view.endEditing(true)
        viewModel.name = usernameField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.email = emailField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.password = passwordField.text
        viewModel.confirmPassword = confirmPasswordField.text
        viewModel.isPrivacyChecked = agreementButton.isSelected
        viewModel.register()
    }

    @objc private func toggleAgreement() {
        agreementButton.isSelected.toggle()
        agreementButton.backgroundColor = agreementButton.isSelected ? .accent : .clear
    }

    @objc private func togglePasswordVisibility() {
        passwordField.textField.isSecureTextEntry.toggle()
    }

    @objc private func toggleConfirmPasswordVisibility() {
        confirmPasswordField.textField.isSecureTextEntry.toggle()
    }

    @objc private func backTapped() {
        coordinator?.dismissAuth()
    }

    @objc private func signInTapped() {
        coordinator?.showSignIn()
    }
}
