//
//  PillTabBar.swift
//  FootballApp
//
//  Created by Servan on 07.10.26.
//

import UIKit

enum AppGradient {
    static let accentStart = UIColor(red: 0.95, green: 0.62, blue: 0.50, alpha: 1)
    static let accentEnd = UIColor(red: 0.88, green: 0.41, blue: 0.30, alpha: 1)
}

/// Seçilən tab narıncı gradient pill, qalanları sadə mətn kimi görünür.
final class PillTabButton: UIButton {

    var isSelectedTab = false {
        didSet { updateAppearance() }
    }

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [AppGradient.accentStart.cgColor, AppGradient.accentEnd.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    init(title: String) {
        super.init(frame: .zero)
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 18, bottom: 13, trailing: 18)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var updated = container
            updated.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            return updated
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
        gradientLayer.opacity = isSelectedTab ? 1 : 0
    }
}

/// Bir neçə tab-dan ibarət sətir. Tab-lar sığmırsa yana scroll olur.
final class PillTabBar: UIView {

    enum Alignment {
        /// Tab-lar bütün eni bərabər aralıqla paylaşır.
        case spread
        /// Tab-lar soldan düzülür, qalan yer boş qalır.
        case leading
    }

    var onSelect: ((Int) -> Void)?
    private(set) var selectedIndex = 0

    private let buttons: [PillTabButton]
    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    init(titles: [String], alignment: Alignment = .spread) {
        buttons = titles.map { PillTabButton(title: $0) }
        super.init(frame: .zero)

        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8

        for (index, button) in buttons.enumerated() {
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.addAction(UIAction { [weak self] _ in
                self?.select(index, notify: true)
            }, for: .touchUpInside)
            stack.addArrangedSubview(button)
        }

        switch alignment {
        case .spread:
            stack.distribution = .equalSpacing
        case .leading:
            stack.distribution = .fill
            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            stack.addArrangedSubview(spacer)
        }

        scrollView.showsHorizontalScrollIndicator = false
        addSubviews(scrollView)
        scrollView.addSubviews(stack)

        scrollView
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor)

        stack
            .top(scrollView.contentLayoutGuide.topAnchor).0
            .leading(scrollView.contentLayoutGuide.leadingAnchor).0
            .trailing(scrollView.contentLayoutGuide.trailingAnchor).0
            .bottom(scrollView.contentLayoutGuide.bottomAnchor)

        // Tab-lar azdırsa görünən eni doldurur (spread / leading işləyir), çoxdursa scroll olur.
        stack.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        // Sətrin hündürlüyü düymələrin hündürlüyündən gəlir.
        scrollView.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor).isActive = true

        select(0, notify: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func select(_ index: Int, notify: Bool) {
        guard buttons.indices.contains(index) else { return }
        selectedIndex = index
        for (buttonIndex, button) in buttons.enumerated() {
            button.isSelectedTab = buttonIndex == index
        }
        guard notify else { return }

        // Seçilən tab görünən hissədən kənardadırsa scroll edib göstər.
        if scrollView.bounds.width > 0 {
            let button = buttons[index]
            let frame = button.convert(button.bounds, to: scrollView).insetBy(dx: -16, dy: 0)
            scrollView.scrollRectToVisible(frame, animated: true)
        }
        onSelect?(index)
    }
}
