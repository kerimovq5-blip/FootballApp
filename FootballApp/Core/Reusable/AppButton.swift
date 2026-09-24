import UIKit

final class AppButton: UIView {

    var onTap: (() -> Void)?

    private enum Layout {
        static let imageSpacing: CGFloat = 8
        static let borderWidth: CGFloat = 1
        static let cornerRadius = AppRadius.buttonRadius.radius
    }

    private lazy var mainButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()

    init(
        title: String,
        backgroundColor: AssetColors? = nil,
        titleColor: AssetColors? = nil,
        image: UIImage? = nil,
        imagePosition: ImagePosition = .leading,
        imageTintColor: AssetColors? = nil,
        borderColor: AssetColors? = nil
    ) {
        super.init(frame: .zero)
        configure(
            title: title,
            backgroundColor: backgroundColor,
            titleColor: titleColor,
            image: image,
            imagePosition: imagePosition,
            imageTintColor: imageTintColor,
            borderColor: borderColor
        )
        setupHierarchy()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(
        title: String,
        backgroundColor: AssetColors?,
        titleColor: AssetColors?,
        image: UIImage?,
        imagePosition: ImagePosition,
        imageTintColor: AssetColors?,
        borderColor: AssetColors?
    ) {
        var config = UIButton.Configuration.filled()
        config.title = title

        if let backgroundColor = backgroundColor {
            config.baseBackgroundColor = backgroundColor.color
        } else {
            config.baseBackgroundColor = .clear
        }

        config.baseForegroundColor = (titleColor ?? .buttonTitlecolor).color
        config.background.cornerRadius = Layout.cornerRadius
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var c = container
            c.font = AppFonts.body.font
            return c
        }

        if let image = image {
            config.image = image
            config.imagePadding = Layout.imageSpacing
            config.imagePlacement = imagePosition == .leading ? .leading : .trailing
            if let tint = imageTintColor {
                config.imageColorTransformer = UIConfigurationColorTransformer { _ in tint.color }
            }
        }

        mainButton.configuration = config

        if let borderColor = borderColor {
            layer.borderColor = borderColor.color.cgColor
            layer.borderWidth = Layout.borderWidth
            layer.cornerRadius = Layout.cornerRadius
        }
    }

    private func setupHierarchy() {
        addSubviews(mainButton)
    }

    private func setupLayout() {
        mainButton
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor)
    }

    @objc private func buttonTapped() {
        onTap?()
    }

    func setTitle(_ title: String) {
        mainButton.configuration?.title = title
    }

    func setIsEnabled(_ isEnabled: Bool) {
        mainButton.isEnabled = isEnabled
        mainButton.alpha = isEnabled ? 1.0 : 0.5
    }

    func setLoading(_ isLoading: Bool) {
        mainButton.configuration?.showsActivityIndicator = isLoading
        mainButton.isEnabled = !isLoading
        mainButton.alpha = isLoading ? 0.6 : 1.0
    }
}
