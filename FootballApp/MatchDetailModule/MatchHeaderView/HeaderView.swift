//
//  HeaderView.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 30.09.26.
//

import UIKit

final class MatchHeaderView: UIView {

    private enum Layout {
        static let crestSize: CGFloat = 56
    }

    private lazy var homeCrestView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var awayCrestView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var homeNameLabel = teamNameLabel()
    private lazy var awayNameLabel = teamNameLabel()

    private lazy var scoreLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.title.font
        l.textColor = .titleColor
        l.textAlignment = .center
        return l
    }()

    private lazy var minuteLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regularBody.font
        l.textColor = .labelColor
        l.textAlignment = .center
        return l
    }()

    private lazy var homeStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [homeCrestView, homeNameLabel])
        s.axis = .vertical
        s.spacing = AppLayout.smallSpacing.value
        s.alignment = .center
        return s
    }()

    private lazy var awayStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [awayCrestView, awayNameLabel])
        s.axis = .vertical
        s.spacing = AppLayout.smallSpacing.value
        s.alignment = .center
        return s
    }()

    private lazy var scoreStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [scoreLabel, minuteLabel])
        s.axis = .vertical
        s.spacing = 2
        s.alignment = .center
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(homeStack, scoreStack, awayStack)

        homeCrestView.width(Layout.crestSize).0.height(Layout.crestSize)
        awayCrestView.width(Layout.crestSize).0.height(Layout.crestSize)

        homeStack
            .leading(leadingAnchor).0
            .top(topAnchor).0
            .bottom(bottomAnchor)

        awayStack
            .trailing(trailingAnchor).0
            .top(topAnchor).0
            .bottom(bottomAnchor)

        scoreStack
            .centerX(centerXAnchor).0
            .centerY(homeStack.centerYAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        homeName: String,
        awayName: String,
        homeCrest: UIImage?,
        awayCrest: UIImage?,
        score: String,
        minuteOrStatus: String
    ) {
        homeNameLabel.text = homeName
        awayNameLabel.text = awayName
        homeCrestView.image = homeCrest
        awayCrestView.image = awayCrest
        scoreLabel.text = score
        minuteLabel.text = minuteOrStatus
    }

    private func teamNameLabel() -> UILabel {
        let l = UILabel()
        l.font = AppFonts.mediumTitle.font
        l.textColor = .titleColor
        l.textAlignment = .center
        return l
    }
}
