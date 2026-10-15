//
//  ClubOverviewView.swift
//  FootballApp
//
//  Created by Servan on 11.10.26.
//


//
//  ClubOverviewView.swift
//  FootballApp
//

import UIKit

final class ClubOverviewView: UIView {

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

    func configure(with content: ClubDetailContent) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let key = ClubKey.make(content.profile.name)

        if let next = content.upcoming.first {
            stack.addArrangedSubview(nextMatchCard(next))
        }
        if let season = seasonCard(content: content, key: key) {
            stack.addArrangedSubview(season)
        }
        if !content.form.isEmpty {
            stack.addArrangedSubview(formCard(content.form))
        }
        stack.addArrangedSubview(infoCard(content.profile))
        if !content.profile.competitions.isEmpty {
            stack.addArrangedSubview(competitionsCard(content.profile.competitions))
        }
    }

    // MARK: - Kartlar

    private func nextMatchCard(_ match: ClubMatch) -> UIView {
        let caption = makeLabel("\(match.dateText) · \(match.competition)",
                                font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                color: UIColor.white.withAlphaComponent(0.6))

        let teams = makeLabel("\(match.home)  vs  \(match.away)",
                              font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                              color: .white)
        teams.numberOfLines = 0

        let status = makeLabel(match.isLive ? "LIVE · \(match.statusText)" : match.statusText,
                               font: UIFont.systemFont(ofSize: 15, weight: .bold),
                               color: match.isLive ? .systemGreen : AppGradient.accentStart)

        let body = UIStackView(arrangedSubviews: [caption, teams, status])
        body.axis = .vertical
        body.spacing = 6
        return makeCard(title: match.isLive ? "Live now" : "Next match", body: body)
    }

    /// Domestik liqadakı mövqe və xal.
    private func seasonCard(content: ClubDetailContent, key: String) -> UIView? {
        guard let table = content.tables.first(where: { $0.league.country != "Europe" }),
              let row = table.standings.first(where: { ClubKey.make($0.teamName) == key }) else { return nil }

        let blocks: [(String, String)] = [
            ("Position", "#\(row.position)"),
            ("Points", "\(row.points)"),
            ("W-D-L", "\(row.wins)-\(row.draws)-\(row.losses)"),
            ("Goals", "\(row.goalsFor):\(row.goalsAgainst)")
        ]
        let stats = UIStackView(arrangedSubviews: blocks.map { makeStatBlock(value: $0.1, caption: $0.0) })
        stats.axis = .horizontal
        stats.distribution = .fillEqually
        return makeCard(title: table.league.name, body: stats)
    }

    private func formCard(_ form: [ClubResult]) -> UIView {
        let chips = UIStackView(arrangedSubviews: form.map { makeFormChip($0) })
        chips.axis = .horizontal
        chips.spacing = 8

        let row = UIStackView(arrangedSubviews: [chips, UIView()])
        row.axis = .horizontal
        return makeCard(title: "Form (last \(form.count))", body: row)
    }

    private func infoCard(_ profile: ClubProfile) -> UIView {
        let country = [profile.flag, profile.country].compactMap { $0 }.joined(separator: " ")
        let items: [(String, String?)] = [
            ("Country", country),
            ("Founded", profile.founded.map { String($0) }),
            ("Stadium", profile.stadium)
        ]

        let rows = UIStackView()
        rows.axis = .vertical
        rows.spacing = 10
        for (title, value) in items {
            let shown = value.flatMap { $0.isEmpty ? nil : $0 } ?? "–"
            rows.addArrangedSubview(makeInfoRow(title, shown))
        }
        return makeCard(title: "Club info", body: rows)
    }

    private func competitionsCard(_ names: [String]) -> UIView {
        let rows = UIStackView(arrangedSubviews: names.map {
            makeLabel($0, font: .regularBody, color: .white)
        })
        rows.axis = .vertical
        rows.spacing = 8
        return makeCard(title: "Competitions", body: rows)
    }

    // MARK: - Hazır parçalar

    private func makeCard(title: String, body: UIView) -> UIView {
        let titleLabel = makeLabel(title, font: .semiBold, color: .white)

        let inner = UIStackView(arrangedSubviews: [titleLabel, body])
        inner.axis = .vertical
        inner.spacing = 12
        inner.isLayoutMarginsRelativeArrangement = true
        inner.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        card.layer.cornerRadius = 14
        card.addSubviews(inner)
        inner
            .top(card.topAnchor).0
            .leading(card.leadingAnchor).0
            .trailing(card.trailingAnchor).0
            .bottom(card.bottomAnchor)
        return card
    }

    private func makeInfoRow(_ title: String, _ value: String) -> UIView {
        let titleLabel = makeLabel(
            title,
            font: .regularBody,
            color: UIColor.white.withAlphaComponent(
                0.6
            )
        )
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        let valueLabel = makeLabel(
            value,
            font: .semiBold,
            color: .white
        )
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .firstBaseline
        return row
    }

    private func makeStatBlock(value: String, caption: String) -> UIView {
        let valueLabel = makeLabel(value, font: UIFont.systemFont(ofSize: 20, weight: .bold), color: .white)
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7

        let captionLabel = makeLabel(caption, font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                     color: UIColor.white.withAlphaComponent(0.6))
        captionLabel.textAlignment = .center

        let block = UIStackView(arrangedSubviews: [valueLabel, captionLabel])
        block.axis = .vertical
        block.spacing = 4
        return block
    }

    private func makeFormChip(_ result: ClubResult) -> UIView {
        let label = makeLabel(result.title, font: UIFont.systemFont(ofSize: 13, weight: .bold), color: .white)
        label.textAlignment = .center
        label.backgroundColor = result.color
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.width(30).0.height(30)
        return label
    }

    private func makeLabel(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        return label
    }
}
