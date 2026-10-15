//
//  PlayerOverviewView.swift
//  FootballApp
//
//  Created by Servan on 12.10.26.
//


//
//  PlayerOverviewView.swift
//  FootballApp
//

import UIKit

final class PlayerOverviewView: UIView {

    /// Club kartına toxunanda çağırılır.
    var onSelectClub: ((ClubReference) -> Void)?

    private var club: ClubReference?

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
        club = content.profile.club

        stack.addArrangedSubview(summaryCard(content))

        // Son 5 oyunun reytinqi, köhnədən yeniyə (ən yenisi sağda).
        let ratings = Array(content.matches.prefix(5).compactMap { $0.rating }.reversed())
        if !ratings.isEmpty {
            stack.addArrangedSubview(ratingsCard(ratings))
        }

        stack.addArrangedSubview(infoCard(content.profile))
        stack.addArrangedSubview(clubCard(content.profile.club))
    }

    // MARK: - Kartlar

    private func summaryCard(_ content: PlayerDetailContent) -> UIView {
        let blocks = UIStackView(arrangedSubviews: content.summary.map {
            InfoUI.statBlock(value: $0.value, caption: $0.label)
        })
        blocks.axis = .horizontal
        blocks.distribution = .fillEqually
        return InfoCardView(title: "Season \(content.season)", body: blocks)
    }

    private func ratingsCard(_ ratings: [Double]) -> UIView {
        let chips = UIStackView(arrangedSubviews: ratings.map { makeRatingChip($0) })
        chips.axis = .horizontal
        chips.spacing = 8

        let row = UIStackView(arrangedSubviews: [chips, UIView()])
        row.axis = .horizontal
        return InfoCardView(title: "Last \(ratings.count) ratings", body: row)
    }

    private func infoCard(_ profile: PlayerProfile) -> UIView {
        let rows = InfoUI.rows([
            ("Position", profile.position.singularTitle),
            ("Nationality", profile.nationality.isEmpty ? "–" : "\(profile.flag) \(profile.nationality)"),
            ("Age", "\(profile.age)"),
            ("Height", "\(profile.heightCm) cm"),
            ("Preferred foot", profile.preferredFoot),
            ("Shirt number", "#\(profile.number)")
        ])
        return InfoCardView(title: "Player info", body: rows)
    }

    /// Toxunanda klub səhifəsi açılır.
    private func clubCard(_ club: ClubReference) -> UIView {
        let crest = ClubCrestView(size: 44, inset: 8)
        crest.configure(initials: club.name)

        let nameLabel = InfoUI.label(club.name, font: AppFonts.semiBold.font, color: .white)
        let countryText = [club.flag, club.country].compactMap { $0 }.joined(separator: " ")
        let countryLabel = InfoUI.label(countryText,
                                        font: UIFont.systemFont(ofSize: 13, weight: .regular),
                                        color: UIColor.white.withAlphaComponent(0.6))

        let textStack = UIStackView(arrangedSubviews: [nameLabel, countryLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor.white.withAlphaComponent(0.4)
        chevron.contentMode = .scaleAspectFit
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [crest, textStack, chevron])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        let card = InfoCardView(title: "Club", body: row)
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clubTapped)))
        return card
    }

    private func makeRatingChip(_ rating: Double) -> UIView {
        let label = InfoUI.label(PlayerRating.text(rating),
                                 font: UIFont.systemFont(ofSize: 14, weight: .bold),
                                 color: .white)
        label.textAlignment = .center
        label.backgroundColor = PlayerRating.color(rating)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.width(46).0.height(30)
        return label
    }

    @objc private func clubTapped() {
        guard let club else { return }
        onSelectClub?(club)
    }
}
