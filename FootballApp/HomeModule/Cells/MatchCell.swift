//
//  MatchCell.swift
//  FootballApp
//
//  Created by Servan on 29.09.26.
//

import UIKit

final class MatchCell: UICollectionViewCell {

    static let reuseID = "MatchCell"

    private lazy var homeLabel = teamLabel()
    private lazy var awayLabel = teamLabel()

    private lazy var teamsStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [homeLabel, awayLabel])
        s.axis = .vertical
        s.spacing = 6
        return s
    }()

    private lazy var scoreLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.titleBold.font
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private lazy var statusLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.semiBold.font
        l.textAlignment = .center
        return l
    }()

    private lazy var container: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 14
        return v
    }()

    private lazy var rowStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [teamsStack, scoreLabel, statusLabel])
        s.axis = .horizontal
        s.alignment = .center
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        s.spacing = 12
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        scoreLabel.setContentHuggingPriority(.required, for: .horizontal)
        statusLabel.width(88)

        contentView.addSubviews(container)
        container.addSubviews(rowStack)

        container
            .top(contentView.topAnchor).0
            .leading(contentView.leadingAnchor).0
            .trailing(contentView.trailingAnchor).0
            .bottom(contentView.bottomAnchor)

        rowStack
            .top(container.topAnchor).0
            .leading(container.leadingAnchor).0
            .trailing(container.trailingAnchor).0
            .bottom(container.bottomAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func teamLabel() -> UILabel {
        let l = UILabel()
        l.font = AppFonts.mediumTitle.font
        l.textColor = .white
        return l
    }

    func configure(with match: Match) {
        homeLabel.text = match.home
        awayLabel.text = match.away
        statusLabel.text = match.status.displayText
        statusLabel.textColor = match.status.isLive ? .systemGreen : UIColor.white.withAlphaComponent(0.6)

        if let home = match.homeScore, let away = match.awayScore {
            scoreLabel.text = "\(home) - \(away)"
        } else {
            scoreLabel.text = ""
        }
    }
}
