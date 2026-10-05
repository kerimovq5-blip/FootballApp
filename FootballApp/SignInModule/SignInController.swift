import UIKit

final class SignInController: UIViewController {

    weak var coordinator : AuthNavigating?
    private let viewModel: SignInViewModel

    init(viewModel: SignInViewModel) {
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
        label.text = "Welcome"
        label.textColor = .titleColor
        label.font = AppFonts.title.font
        label.textAlignment = .center
        return label
    }()

    private let emailField = AppTextField(
        placeholder: "Email",
        textColor: .labelColor,
        leftIcon: UIImage(named: "emailicon")
    )

    private lazy var passwordField: AppTextField = {
        let toggleButton = makePasswordToggleButton(action: #selector(togglePasswordVisibility))
        
        let passwordField = AppTextField(
            placeholder: "Password",
            isSecure: true,
            textColor: .labelColor,
            leftIcon: UIImage(named: "passwordicon"),
            rightView: toggleButton
        )
        return passwordField
    }()

    private lazy var rememberMeCheckbox: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.labelColor.cgColor
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(toggleRememberMe), for: .touchUpInside)
        return button
    }()

    private lazy var rememberMeLabel: UILabel = {
        let label = UILabel()
        label.text = "Remember me"
        label.textColor = .labelColor
        label.font = AppFonts.regularBody.font
        return label
    }()

    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password", for: .normal)
        button.setTitleColor(.titleColor, for: .normal)
        button.titleLabel?.font = AppFonts.regularBody.font
        button.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        return button
    }()

    private lazy var signInButton: AppButton = {
        let button = AppButton(
            title: "Sign in",
            backgroundColor: .accent,
            titleColor: .titleColor
        )
        button.onTap = { [weak self] in
            self?.signInTapped()
        }
        return button
    }()

    private lazy var signUpPromptButton: UIButton = {
        let button = UIButton(type: .system)
        let text = NSMutableAttributedString(
            string: "Don’t have account? ",
            attributes: [
                .foregroundColor: AssetColors.labelColor.color,
                .font: AppFonts.regularBody.font
            ]
        )
        text.append(NSAttributedString(
            string: "Sign UP",
            attributes: [
                .foregroundColor: UIColor.accent,
                .font: AppFonts.regularBody.font
            ]
        ))
        button.setAttributedTitle(text, for: .normal)
        button.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        configureFields()
        bindViewModel()
    }

    private func configureFields() {
        emailField.textField.keyboardType = .emailAddress
        emailField.textField.autocapitalizationType = .none
        emailField.textField.autocorrectionType = .no
        passwordField.textField.autocapitalizationType = .none
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] in
            guard let self else { return }
            switch self.viewModel.state {
            case .idle, .success:
                self.signInButton.setLoading(false)
            case .loading:
                self.signInButton.setLoading(true)
            case .invalidInput(let message):
                self.signInButton.setLoading(false)
                self.showAlert(message: message)
            case .requestFailed(let error):
                self.signInButton.setLoading(false)
                self.showAlert(message: error.localizedDescription)
            }
        }
    }

    private func signInTapped() {
        view.endEditing(true)
        viewModel.email = emailField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.password = passwordField.text
        viewModel.login()
    }

    private func setupHierarchy() {
        view.backgroundColor = AssetColors.backgroundColor2.color
        view.addSubviews(
            welcomeLabel,
            emailField,
            passwordField,
            rememberMeCheckbox,
            rememberMeLabel,
            forgotPasswordButton,
            signInButton,
            signUpPromptButton
        )
    }

    private func setupLayout() {
        welcomeLabel
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .top(view.topAnchor, AppLayout.mediumSpacing.value)

        emailField
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .top(welcomeLabel.bottomAnchor, AppLayout.mediumSpacing.value).0
            .height(Metrics.fieldHeight)

        passwordField
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .top(emailField.bottomAnchor, AppLayout.mediumSpacing.value).0
            .height(Metrics.fieldHeight)

        rememberMeCheckbox
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .top(passwordField.bottomAnchor, AppLayout.mediumSpacing.value).0
            .width(Metrics.checkboxSize).0
            .height(Metrics.checkboxSize)

        rememberMeLabel
            .centerY(rememberMeCheckbox.centerYAnchor).0
            .leading(rememberMeCheckbox.trailingAnchor, AppLayout.smallSpacing.value)

        forgotPasswordButton
            .centerY(rememberMeCheckbox.centerYAnchor).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value)

        signInButton
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .top(rememberMeCheckbox.bottomAnchor, AppLayout.largeSpacing.value).0
            .height(Metrics.buttonHeight)

        signUpPromptButton
            .centerX(view.centerXAnchor).0
            .top(signInButton.bottomAnchor, AppLayout.mediumSpacing.value)
    }

    @objc private func togglePasswordVisibility() {
        passwordField.textField.isSecureTextEntry.toggle()
    }

    @objc private func toggleRememberMe() {
        rememberMeCheckbox.isSelected.toggle()
        rememberMeCheckbox.backgroundColor = rememberMeCheckbox.isSelected ? .accent : .clear
    }

    @objc private func forgotPasswordTapped() {
       
    }

    @objc private func signUpTapped() {
        coordinator?.showSignUp()
    }
}
