import UIKit

final class H2HMeetingRow: UIView {

    private lazy var dateLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.litletitle.font
        l.textColor = .labelColor
        return l
    }()

    private lazy var competitionLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.mediumTitle.font
        l.textColor = .titleColor
        return l
    }()

    private lazy var textStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [competitionLabel, dateLabel])
        s.axis = .vertical
        s.spacing = 2
        return s
    }()

    private lazy var matchupLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regularBody.font
        l.textColor = .titleColor
        l.textAlignment = .right
        return l
    }()

    private lazy var scoreLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.semiBold.font
        l.textColor = .accent
        l.textAlignment = .right
        return l
    }()

    private lazy var scoreStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [matchupLabel, scoreLabel])
        s.axis = .vertical
        s.alignment = .trailing
        s.spacing = 2
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(textStack, scoreStack)
        textStack
            .leading(leadingAnchor).0
            .top(topAnchor, AppLayout.smallSpacing.value).0
            .bottom(bottomAnchor, -AppLayout.smallSpacing.value)
        scoreStack
            .trailing(trailingAnchor).0
            .centerY(textStack.centerYAnchor).0
            .leading(textStack.trailingAnchor, AppLayout.smallSpacing.value)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with meeting: H2HMatch) {
        competitionLabel.text = meeting.competition
        dateLabel.text = meeting.date
        matchupLabel.text = "\(meeting.homeTeam) vs \(meeting.awayTeam)"
        scoreLabel.text = "\(meeting.homeScore) - \(meeting.awayScore)"
    }
}//
//  H2HMeetingRow.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 30.09.26.
//

