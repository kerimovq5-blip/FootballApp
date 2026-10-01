//
//  LeagueStandingCell.swift
//  FootballApp
//
//  Created by Servan on 01.10.26.
//
import UIKit

final class LeagueStandingCell: UITableViewCell {

    static let reuseID = "LeagueStandingCell"

    private lazy var positionLabel = makeLabel(font: .semiBold, alignment: .center)
    private lazy var crestView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private lazy var teamLabel = makeLabel(font: .mediumTitle, alignment: .left)
    private lazy var playedLabel = makeLabel(font: .regularBody, alignment: .center)
    private lazy var winsLabel = makeLabel(font: .regularBody, alignment: .center)
    private lazy var drawsLabel = makeLabel(font: .regularBody, alignment: .center)
    private lazy var lossesLabel = makeLabel(font: .regularBody, alignment: .center)
    private lazy var goalsForLabel = makeLabel(font: .regularBody, alignment: .center)
    private lazy var goalsAgainstLabel = makeLabel(font: .regularBody, alignment: .center)
    private lazy var goalDiffLabel = makeLabel(font: .regularBody, alignment: .center)
    private lazy var pointsLabel = makeLabel(font: .semiBold, alignment: .center)

    private lazy var container: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 14
        return v
    }()

    private lazy var teamStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [crestView, teamLabel])
        s.axis = .horizontal
        s.spacing = 8
        s.alignment = .center
        return s
    }()

    private lazy var rowStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [
            positionLabel, teamStack, playedLabel, winsLabel, drawsLabel,
            lossesLabel, goalsForLabel, goalsAgainstLabel, goalDiffLabel, pointsLabel
        ])
        s.axis = .horizontal
        s.alignment = .center
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        s.spacing = 6
        return s
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        positionLabel.width(16)
        crestView.width(20).0.height(20)
        teamLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        [playedLabel, winsLabel, drawsLabel, lossesLabel,
         goalsForLabel, goalsAgainstLabel, goalDiffLabel].forEach { $0.width(22) }
        pointsLabel.width(28)

        contentView.addSubviews(container)
        container.addSubviews(rowStack)
        container
            .top(contentView.topAnchor, 4).0
            .leading(contentView.leadingAnchor).0
            .trailing(contentView.trailingAnchor).0
            .bottom(contentView.bottomAnchor, -4)
        rowStack
            .top(container.topAnchor).0
            .leading(container.leadingAnchor).0
            .trailing(container.trailingAnchor).0
            .bottom(container.bottomAnchor)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeLabel(font: AppFonts, alignment: NSTextAlignment) -> UILabel {
        let l = UILabel()
        l.font = font.font
        l.textColor = .white
        l.textAlignment = alignment
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        return l
    }

    func configure(with standing: Standing) {
        positionLabel.text = "\(standing.position)"
        teamLabel.text = standing.teamName
        crestView.image = standing.crestImageName.flatMap(UIImage.init(named:))
        playedLabel.text = "\(standing.played)"
        winsLabel.text = "\(standing.wins)"
        drawsLabel.text = "\(standing.draws)"
        lossesLabel.text = "\(standing.losses)"
        goalsForLabel.text = "\(standing.goalsFor)"
        goalsAgainstLabel.text = "\(standing.goalsAgainst)"
        goalDiffLabel.text = "\(standing.goalDifference)"
        pointsLabel.text = "\(standing.points)"
        container.backgroundColor = standing.zone.backgroundColor
    }
}
