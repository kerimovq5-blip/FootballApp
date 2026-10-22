//
//  StateView.swift
//  FootballApp
//

import UIKit

/// Ekranın data hissəsinin üstünü örtən vəziyyət görünüşü:
/// yüklənir (spinner), xəta (ikona + mesaj + "Try again") və ya boş siyahı mesajı.
///
///     stateView.onRetry = { [weak self] in self?.viewModel.load() }
///     stateView.showLoading()
///     stateView.show(error)
///     stateView.hide()
final class StateView: UIView {

    var onRetry: (() -> Void)?

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.hidesWhenStopped = true
        return spinner
    }()

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor.white.withAlphaComponent(0.5)
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 44, weight: .light)
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .regularBody
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Try again"
        config.image = UIImage(systemName: "arrow.clockwise")
        config.imagePadding = 8
        config.cornerStyle = .capsule
        config.baseBackgroundColor = AppGradient.accentEnd
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 22, bottom: 12, trailing: 22)
        let button = UIButton(configuration: config)
        button.addAction(UIAction { [weak self] _ in
            self?.onRetry?()
        }, for: .touchUpInside)
        return button
    }()

    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [spinner, iconView, titleLabel, messageLabel, retryButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.setCustomSpacing(4, after: titleLabel)
        stack.setCustomSpacing(24, after: messageLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        ])
        hide()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// `target`-in üstünə, eyni ölçüdə yerləşdirir. İkisi də eyni superview-da olmalıdır.
    func pinEdges(to target: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: target.topAnchor),
            leadingAnchor.constraint(equalTo: target.leadingAnchor),
            trailingAnchor.constraint(equalTo: target.trailingAnchor),
            bottomAnchor.constraint(equalTo: target.bottomAnchor)
        ])
    }

    // MARK: - Vəziyyətlər

    func showLoading() {
        isHidden = false
        spinner.startAnimating()
        [iconView, titleLabel, messageLabel, retryButton].forEach { $0.isHidden = true }
    }

    func show(_ error: UserFacingError) {
        show(symbolName: error.symbolName, title: error.title, message: error.message,
             showsRetry: error.canRetry)
    }

    /// Boş siyahı və ya digər məlumat mesajı üçün.
    func show(symbolName: String, title: String, message: String?, showsRetry: Bool = false) {
        isHidden = false
        spinner.stopAnimating()
        iconView.image = UIImage(systemName: symbolName)
        titleLabel.text = title
        messageLabel.text = message
        iconView.isHidden = false
        titleLabel.isHidden = false
        messageLabel.isHidden = message == nil
        retryButton.isHidden = !showsRetry || onRetry == nil
    }

    func hide() {
        spinner.stopAnimating()
        isHidden = true
    }
}
