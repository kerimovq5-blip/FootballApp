import UIKit

final class AppTextField: UIView {

    var text: String {
        get { mainTextField.text ?? "" }
        set { mainTextField.text = newValue }
    }

    var textField: UITextField { mainTextField }

    private enum Layout {
        static let fontSize: CGFloat = 18
        static let leftPadding: CGFloat = 12
        static let leftIconSize: CGFloat = 24
        static let leftContainerWidth: CGFloat = 48
        static let rightContainerWidth: CGFloat = 45
        static let rightContainerHeight: CGFloat = 30
        static let rightButtonSize: CGFloat = 30
        static let cornerRadius: CGFloat = 16
        static let height: CGFloat = 56
    }

    private lazy var mainTextField: UITextField = {
        let textField = UITextField()
        textField.font = AppFonts.body.font.withSize(Layout.fontSize)
        textField.layer.cornerRadius = Layout.cornerRadius
        textField.clipsToBounds = true
        return textField
    }()

    init(
        placeholder: String,
        isSecure: Bool = false,
        backgroundColor: AssetColors? = nil,
        textColor: AssetColors? = nil,
        delegate: UITextFieldDelegate? = nil,
        leftIcon: UIImage? = nil,
        rightView: UIButton? = nil
    ) {
        super.init(frame: .zero)
        configure(
            placeholder: placeholder,
            isSecure: isSecure,
            backgroundColor: backgroundColor,
            textColor: textColor,
            delegate: delegate,
            leftIcon: leftIcon,
            rightView: rightView
        )
        setupHierarchy()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(
        placeholder: String,
        isSecure: Bool,
        backgroundColor: AssetColors?,
        textColor: AssetColors?,
        delegate: UITextFieldDelegate?,
        leftIcon: UIImage?,
        rightView: UIButton?
    ) {
        mainTextField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .font: AppFonts.regularBody.font,
                .foregroundColor: UIColor.textSecondary
            ]
        )
        mainTextField.isSecureTextEntry = isSecure
        mainTextField.backgroundColor = (backgroundColor ?? .background).color
        mainTextField.textColor = textColor?.color
        mainTextField.delegate = delegate

        if let leftIcon = leftIcon {
            let iconView = UIImageView(image: leftIcon)
            iconView.frame = CGRect(x: 0, y: 0, width: Layout.leftIconSize, height: Layout.leftIconSize)
            let container = UIView(frame: CGRect(x: 0, y: 0, width: Layout.leftContainerWidth, height: Layout.height))
            iconView.center = container.center
            container.addSubview(iconView)
            mainTextField.leftView = container
        } else {
            let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: Layout.leftPadding, height: 0))
            mainTextField.leftView = leftPadding
        }
        mainTextField.leftViewMode = .always

        if let rightButton = rightView {
            let container = UIView(frame: CGRect(
                x: 0, y: 0,
                width: Layout.rightContainerWidth,
                height: Layout.rightContainerHeight
            ))
            rightButton.frame = CGRect(
                x: 0, y: 0,
                width: Layout.rightButtonSize,
                height: Layout.rightButtonSize
            )
            container.addSubview(rightButton)
            mainTextField.rightView = container
            mainTextField.rightViewMode = .always
        }
    }

    private func setupHierarchy() {
        addSubviews(mainTextField)
    }

    private func setupLayout() {
        mainTextField
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor)
    }
}
