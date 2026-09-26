import UIKit

final class SignInController: UIViewController {

    var onSignInTapped: (() -> Void)?
    var onSignUpTapped: (() -> Void)?
    var onForgotPasswordTapped: (() -> Void)?

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

    private lazy var emailField : AppTextField = {
        let emailField = AppTextField(
        placeholder: "Email",
        textColor: .labelColor,
        
        leftIcon: UIImage(named: "emailicon")
        )
        emailField.textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [.foregroundColor: UIColor(named: "placeholdercolor")])
        return emailField
        
    } ()

    private lazy var passwordField: AppTextField = {
        let toggleButton = UIButton()
        toggleButton.setImage(UIImage(named: "hidepassword"), for: .normal)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
      let passwordField = AppTextField(
    placeholder: "Password",
    isSecure: true,
    textColor: .labelColor,
    leftIcon: UIImage(named: "passwordicon"),
    rightView: toggleButton
      )
        passwordField.textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [.foregroundColor: UIColor(named: "placeholdercolor")])
        return passwordField
            
        
    }()

    private lazy var rememberMeCheckbox: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(toggleRememberMe), for: .touchUpInside)
        return button
    }()

    private lazy var rememberMeLabel: UILabel = {
        let label = UILabel()
        label.text = "Remember me"
        label.textColor = UIColor.gray
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
            self?.onSignInTapped?()
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
    }

    private func setupHierarchy() {
        view.backgroundColor = UIColor(named: "mbappeback")
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
            //.trailing(view.trailingAnchor, -AppLayout.screenPadding.value).0
            .top(view.topAnchor,AppLayout.mediumSpacing.value)

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
        onForgotPasswordTapped?()
    }

    @objc private func signUpTapped() {
        onSignUpTapped?()
    }
}
