import UIKit

final class SignUpController: UIViewController {

    var onSignUpTapped: (() -> Void)?
    var onSignInTapped: (() -> Void)?

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
    
    private lazy var usernameField: AppTextField = {
        let field = AppTextField(
            placeholder: "Username",
            textColor: .labelColor,
            leftIcon: UIImage(named: "usericon")?.withRenderingMode(.alwaysTemplate)
        )
        field.textField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [.foregroundColor: UIColor(named: "placeholdercolor")])
        return field
    }()

    private lazy var emailField: AppTextField = {
        let field = AppTextField(
            placeholder: "Email",
            textColor: .labelColor,
            leftIcon: UIImage(named: "emailicon")
        )
        field.textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [.foregroundColor: UIColor(named: "placeholdercolor")])
        return field
    }()

    private lazy var passwordField: AppTextField = {
        let toggleButton = UIButton()
        toggleButton.setImage(UIImage(named: "hidepassword"), for: .normal)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        let field = AppTextField(
            placeholder: "Password",
            isSecure: true,
            textColor: .labelColor,
            leftIcon: UIImage(named: "passwordicon"),
            rightView: toggleButton
        )
        field.textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [.foregroundColor: UIColor(named: "placeholdercolor")])
        return field
    }()

    private lazy var confirmPasswordField: AppTextField = {
        let toggleButton = UIButton()
        toggleButton.setImage(UIImage(named: "hidepassword"), for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility), for: .touchUpInside)
        let field = AppTextField(
            placeholder: "Confirm password",
            isSecure: true,
            textColor: .labelColor,
            leftIcon: UIImage(named: "passwordicon"),
            rightView: toggleButton
        )
        field.textField.attributedPlaceholder = NSAttributedString(string: "Confirm password", attributes: [.foregroundColor: UIColor(named: "placeholdercolor")])
        return field
    }()
    
    private lazy var agreementLabel: UILabel = {
        let label = UILabel()
        let attributed = NSMutableAttributedString(string: "I have read the ",attributes: [.foregroundColor: UIColor(named: "placeholdercolor"),.font: UIFont.systemFont(ofSize: 16,weight: .semibold)])
        attributed.append(NSAttributedString(string: "Privace Policy",attributes: [.foregroundColor: UIColor.systemBlue,.font: UIFont.systemFont(ofSize: 16,weight: .semibold)]))
        label.attributedText = attributed
        label.numberOfLines = 0
        return label
    }()
    private lazy var agreementButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
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
    
    @objc func toggleAgreement() {
        agreementButton.isSelected.toggle()
        agreementButton.backgroundColor = agreementButton.isSelected ? .accent : .clear
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "mbappeback")
        configureNavbar()
        setupHierarchy()
        setupLayout()
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
            .trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .top(confirmPasswordField.bottomAnchor, AppLayout.mediumSpacing.value)
        agreementButton
            .trailing(view.trailingAnchor, -AppLayout.mediumSpacing.value).0
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
        guard
            let email = emailField.textField.text, !email.isEmpty,
            let password = passwordField.textField.text, !password.isEmpty,
            let confirmPassword = confirmPasswordField.textField.text, !confirmPassword.isEmpty
        else {
            return
        }

        guard password == confirmPassword else {
            
            return
        }

        // TODO: AuthService ilə qeydiyyat
        onSignUpTapped?()
    }

    @objc private func togglePasswordVisibility() {
        passwordField.textField.isSecureTextEntry.toggle()
    }

    @objc private func toggleConfirmPasswordVisibility() {
        confirmPasswordField.textField.isSecureTextEntry.toggle()
    }

    @objc private func backTapped() {
        dismiss(animated: true)
    }

    @objc private func signInTapped() {
        onSignInTapped?()
    }
}
