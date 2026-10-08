    //
//  ProfileInfoRow.swift
//  FootballApp
//
//  Created by Servan on 08.10.26.
//

import UIKit

/// Profil ekranındakı sətir: ikon, başlıq, dəyər və sağda çevron / açar.
final class ProfileInfoRow: UIControl {

    enum Accessory {
        case none
        case chevron
        case toggle
    }

    var onTap: (() -> Void)?
    var onToggle: ((Bool) -> Void)?

    override var isHighlighted: Bool {
        didSet { alpha = (isHighlighted && accessory == .chevron) ? 0.6 : 1 }
    }

    private let accessory: Accessory
    private let underlined: Bool

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

    private let toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = AppGradient.accentEnd
        return toggle
    }()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return view
    }()

    init(icon: String,
         title: String,
         value: String,
         underlined: Bool = false,
         accessory: Accessory = .none) {
        self.accessory = accessory
        self.underlined = underlined
        super.init(frame: .zero)

        iconView.image = UIImage(systemName: icon)
        titleLabel.text = title
        setValue(value)

        setupHierarchy()
        setupLayout()

        if accessory == .chevron {
            addTarget(self, action: #selector(rowTapped), for: .touchUpInside)
        }
        toggle.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.onToggle?(self.toggle.isOn)
        }, for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func setValue(_ value: String) {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: AppFonts.regularBody.font.pointSize, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.7)
        ]
        if underlined { attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue }
        valueLabel.attributedText = NSAttributedString(string: value, attributes: attributes)
    }

    func setToggle(isOn: Bool) {
        toggle.setOn(isOn, animated: false)
    }

    func setToggleEnabled(_ enabled: Bool) {
        toggle.isEnabled = enabled
        alpha = enabled ? 1 : 0.45
    }

    // MARK: - Setup

    private var accessoryLeadingAnchor: NSLayoutXAxisAnchor {
        switch accessory {
        case .none: return trailingAnchor
        case .chevron: return chevronView.leadingAnchor
        case .toggle: return toggle.leadingAnchor
        }
    }

    private func setupHierarchy() {
        iconContainer.addSubviews(iconView)
        addSubviews(iconContainer, titleLabel, valueLabel, divider)
        switch accessory {
        case .none: break
        case .chevron: addSubviews(chevronView)
        case .toggle: addSubviews(toggle)
        }
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

        // Uzun mətnlər sağdakı çevron / açarın üstünə çıxmasın.
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: accessoryLeadingAnchor, constant: -12).isActive = true
        valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: accessoryLeadingAnchor, constant: -12).isActive = true

        var dividerTrailing: CGFloat = 0
        switch accessory {
        case .none:
            break
        case .chevron:
            chevronView
                .trailing(trailingAnchor).0
                .centerY(iconContainer.centerYAnchor).0
                .width(14).0
                .height(18)
            dividerTrailing = -44
        case .toggle:
            toggle
                .trailing(trailingAnchor).0
                .centerY(iconContainer.centerYAnchor)
            dividerTrailing = -64
        }

        divider
            .top(valueLabel.bottomAnchor, 16).0
            .leading(titleLabel.leadingAnchor).0
            .trailing(trailingAnchor, dividerTrailing).0
            .bottom(bottomAnchor).0
            .height(1)
    }

    @objc private func rowTapped() {
        onTap?()
    }
}
