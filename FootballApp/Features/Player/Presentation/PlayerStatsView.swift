//
//  PlayerStatsView.swift
//  FootballApp
//
//  Created by Servan on 12.10.26.
//

//
//  PlayerStatsView.swift
//  FootballApp
//

import UIKit

final class PlayerStatsView: UIView {

    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        scrollView.showsVerticalScrollIndicator = false
        stack.axis = .vertical
        stack.spacing = 14
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0,
                                           left: AppLayout.screenPadding.value,
                                           bottom: 24,
                                           right: AppLayout.screenPadding.value)

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
            .bottom(scrollView.contentLayoutGuide.bottomAnchor).0
            .width(scrollView.frameLayoutGuide.widthAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with content: PlayerDetailContent) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let caption = InfoUI.label("Season \(content.season) · all competitions",
                                   font: .regularBody,
                                   color: UIColor.white.withAlphaComponent(0.6))
        stack.addArrangedSubview(caption)

        for section in content.statistics {
            let rows = InfoUI.rows(section.rows.map { ($0.label, $0.value) })
            stack.addArrangedSubview(InfoCardView(title: section.title, body: rows))
        }
    }
}
