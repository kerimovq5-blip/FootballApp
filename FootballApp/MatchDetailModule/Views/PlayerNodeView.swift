//
//  PlayerNodeView.swift
//  FootballApp
//
//  Created by Servan on 07.10.26.
//

import UIKit

/// Meydançadakı bir oyunçu: nömrəli dairə, altında ad etiketi, küncdə kapitan / qol / kart nişanları.
final class PlayerNodeView: UIView {

    static let circleSize: CGFloat = 28

    private enum Layout {
        static let namePaddingX: CGFloat = 7
        static let namePaddingY: CGFloat = 2.5
        static let badgeSize: CGFloat = 14
    }

    private enum Palette {
        static let confirmedFill = UIColor(red: 0.27, green: 0.69, blue: 0.49, alpha: 1)
        static let predictedFill = UIColor.white.withAlphaComponent(0.16)
        static let border = UIColor.white.withAlphaComponent(0.55)
        static let namePill = UIColor.black.withAlphaComponent(0.32)
    }

    private let circleView = UIView()
    private let numberLabel = UILabel()
    private let namePill = UIView()
    private let nameLabel = UILabel()
    private let badgeStack = UIStackView()
    private var nameWidthConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func configure(player: LineupPlayer, isPredicted: Bool) {
        numberLabel.text = "\(player.number)"
        nameLabel.text = player.name
        circleView.backgroundColor = isPredicted ? Palette.predictedFill : Palette.confirmedFill
        circleView.layer.borderColor = (isPredicted ? UIColor.white.withAlphaComponent(0.85) : Palette.border).cgColor

        badgeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // Təxmini heyətdə hadisə nişanı olmur (oyun hələ başlamayıb).
        guard !isPredicted else { return }

        if player.isCaptain { badgeStack.addArrangedSubview(makeCaptainBadge()) }
        if player.goals > 0 { badgeStack.addArrangedSubview(makeGoalBadge(count: player.goals)) }
        if player.yellowCards > 0 { badgeStack.addArrangedSubview(makeCardBadge(color: .systemYellow)) }
        if player.isSentOff { badgeStack.addArrangedSubview(makeCardBadge(color: .systemRed)) }
    }

    /// Ad etiketinin (pill) maksimum eni; uzun adlar kəsilir.
    func setMaxNameWidth(_ width: CGFloat) {
        nameWidthConstraint?.constant = max(30, width - Layout.namePaddingX * 2)
    }

    // MARK: - Setup

    private func setupViews() {
        circleView.layer.cornerRadius = PlayerNodeView.circleSize / 2
        circleView.layer.borderWidth = 1.5

        numberLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center
        circleView.addSubviews(numberLabel)
        numberLabel
            .centerX(circleView.centerXAnchor).0
            .centerY(circleView.centerYAnchor)

        namePill.backgroundColor = Palette.namePill
        namePill.layer.cornerRadius = 9
        nameLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.lineBreakMode = .byTruncatingTail
        namePill.addSubviews(nameLabel)
        nameLabel
            .top(namePill.topAnchor, Layout.namePaddingY).0
            .bottom(namePill.bottomAnchor, -Layout.namePaddingY).0
            .leading(namePill.leadingAnchor, Layout.namePaddingX).0
            .trailing(namePill.trailingAnchor, -Layout.namePaddingX)

        let widthConstraint = nameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 80)
        widthConstraint.isActive = true
        nameWidthConstraint = widthConstraint

        let column = UIStackView(arrangedSubviews: [circleView, namePill])
        column.axis = .vertical
        column.alignment = .center
        column.spacing = 3
        addSubviews(column)
        column
            .top(topAnchor).0
            .bottom(bottomAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor)

        circleView
            .width(PlayerNodeView.circleSize).0
            .height(PlayerNodeView.circleSize)

        badgeStack.axis = .horizontal
        badgeStack.spacing = 1
        badgeStack.alignment = .center
        addSubviews(badgeStack)
        badgeStack
            .bottom(circleView.topAnchor, 8).0
            .trailing(circleView.trailingAnchor, 8)
    }

    // MARK: - Badges

    private func makeCaptainBadge() -> UIView {
        let badge = UIView()
        badge.backgroundColor = .white
        badge.layer.cornerRadius = Layout.badgeSize / 2
        badge.width(Layout.badgeSize).0.height(Layout.badgeSize)

        let label = UILabel()
        label.text = "C"
        label.font = UIFont.systemFont(ofSize: 9, weight: .heavy)
        label.textColor = .black
        badge.addSubviews(label)
        label
            .centerX(badge.centerXAnchor).0
            .centerY(badge.centerYAnchor)
        return badge
    }

    private func makeGoalBadge(count: Int) -> UIView {
        let label = UILabel()
        label.text = count > 1 ? "⚽\(count)" : "⚽"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }

    private func makeCardBadge(color: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = color
        card.layer.cornerRadius = 1.5
        card.width(8).0.height(11)
        return card
    }
}
