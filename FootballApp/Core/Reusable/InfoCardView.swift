//
//  InfoCardView.swift
//  FootballApp
//
//  Created by Servan on 12.10.26.
//


//
//  InfoCardView.swift
//  FootballApp
//

import UIKit

/// Başlıqlı yuvarlaq künclü kart.
final class InfoCardView: UIView {

    init(title: String, body: UIView) {
        super.init(frame: .zero)
        backgroundColor = UIColor.white.withAlphaComponent(0.08)
        layer.cornerRadius = 14

        let titleLabel = InfoUI.label(title, font: AppFonts.semiBold.font, color: .white)
        let inner = UIStackView(arrangedSubviews: [titleLabel, body])
        inner.axis = .vertical
        inner.spacing = 12
        inner.isLayoutMarginsRelativeArrangement = true
        inner.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        addSubviews(inner)
        inner
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum InfoUI {

    static func label(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        return label
    }

    /// "Başlıq ........ dəyər" sətri.
    static func row(_ title: String, _ value: String) -> UIView {
        let titleLabel = label(title, font: AppFonts.regularBody.font,
                               color: UIColor.white.withAlphaComponent(0.6))
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        let valueLabel = label(value, font: AppFonts.semiBold.font, color: .white)
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .firstBaseline
        return row
    }

    static func rows(_ items: [(String, String)]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: items.map { row($0.0, $0.1) })
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }

    /// Böyük rəqəm və altında kiçik izah.
    static func statBlock(value: String, caption: String) -> UIView {
        let valueLabel = label(value, font: UIFont.systemFont(ofSize: 20, weight: .bold), color: .white)
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7

        let captionLabel = label(caption, font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                 color: UIColor.white.withAlphaComponent(0.6))
        captionLabel.textAlignment = .center

        let block = UIStackView(arrangedSubviews: [valueLabel, captionLabel])
        block.axis = .vertical
        block.spacing = 4
        return block
    }
}