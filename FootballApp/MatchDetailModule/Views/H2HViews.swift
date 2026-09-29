//
//  H2HViews.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 30.09.26.
//

import UIKit

final class H2HView: UIView {

    private lazy var summaryView = H2HSummaryView()

    private lazy var meetingsTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Last 5 Meetings"
        l.font = AppFonts.semiBold.font
        l.textColor = .titleColor
        return l
    }()

    private lazy var meetingsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = AppLayout.smallSpacing.value
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(summaryView, meetingsTitleLabel, meetingsStack)
        summaryView
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor)
        meetingsTitleLabel
            .top(summaryView.bottomAnchor, AppLayout.mediumSpacing.value).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor)
        meetingsStack
            .top(meetingsTitleLabel.bottomAnchor, AppLayout.smallSpacing.value).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with h2h: HeadToHead) {
        summaryView.configure(
            homeWins: h2h.homeWins,
            draws: h2h.draws,
            awayWins: h2h.awayWins
        )
        meetingsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        h2h.meetings.forEach { meeting in
            let row = H2HMeetingRow()
            row.configure(with: meeting)
            meetingsStack.addArrangedSubview(row)
        }
    }
}
