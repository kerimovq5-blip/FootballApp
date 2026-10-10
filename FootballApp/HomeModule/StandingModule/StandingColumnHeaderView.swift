//
//  StandingColumnHeaderView.swift
//  FootballApp
//
//  Created by Servan on 10.10.26.
//

//
//  StandingColumnHeaderView.swift
//  FootballApp
//

import UIKit

/// "# Team P W D L GF GA GD Pts" başlıq sətri. Sütun enləri LeagueStandingCell ilə eynidir.
final class StandingColumnHeaderView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeLabel(_ text: String, alignment: NSTextAlignment, width: CGFloat? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = AppFonts.regularBody.font
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = alignment
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        if let width { label.width(width) }
        return label
    }

    private func setupViews() {
        let crestSpacer = UIView()
        crestSpacer.width(20)

        let team = makeLabel("Team", alignment: .left)
        team.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let teamGroup = UIStackView(arrangedSubviews: [crestSpacer, team])
        teamGroup.axis = .horizontal
        teamGroup.spacing = 8

        let columns: [(String, CGFloat)] = [
            ("P", 22), ("W", 22), ("D", 22), ("L", 22),
            ("GF", 22), ("GA", 22), ("GD", 22), ("Pts", 28)
        ]
        var views: [UIView] = [makeLabel("#", alignment: .center, width: 16), teamGroup]
        views += columns.map { makeLabel($0.0, alignment: .center, width: $0.1) }

        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.spacing = 6
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        addSubviews(stack)
        stack
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor)
    }
}
