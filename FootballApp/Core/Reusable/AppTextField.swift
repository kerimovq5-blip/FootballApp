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
        static let rightContainerWidth: CGFloat = 45
        static let rightContainerHeight: CGFloat = 30
        static let rightButtonSize: CGFloat = 30
        static let cornerRadius: CGFloat = 16
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
        textColor: AssetColors = .buttonTitlecolor,
        delegate: UITextFieldDelegate? = nil,
        rightView: UIButton? = nil ,
        leftIcon : UIImage? = nil
    ) {
        super.init(frame: .zero)
        configure(
            placeholder: placeholder,
            isSecure: isSecure,
            backgroundColor: backgroundColor,
            textColor: textColor,
            delegate: delegate,
            rightView: rightView ,
            leftIcon: leftIcon
            
            
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
        textColor: AssetColors,
        delegate: UITextFieldDelegate?,
        rightView: UIButton? ,
        leftIcon : UIImage?
    ) {
        mainTextField.placeholder = placeholder
        mainTextField.isSecureTextEntry = isSecure
        mainTextField.backgroundColor = (backgroundColor ?? .background).color
        mainTextField.textColor = textColor.color
        mainTextField.delegate = delegate

        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: Layout.leftPadding, height: 0))
        mainTextField.leftView = leftPadding
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
