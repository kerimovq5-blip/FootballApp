//
//  MatchDetailView.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 30.09.26.
//

import UIKit

final class H2HSummaryView: UIView {

    private enum Layout {
        static let barHeight: CGFloat = 8
        static let barCornerRadius: CGFloat = 4
    }

    private lazy var homeCountLabel = countLabel()
    private lazy var drawCountLabel = countLabel()
    private lazy var awayCountLabel = countLabel()

    private lazy var homeCaptionLabel = captionLabel(text: "Wins")
    private lazy var drawCaptionLabel = captionLabel(text: "Draws")
    private lazy var awayCaptionLabel = captionLabel(text: "Wins")

    private lazy var homeBar: UIView = {
        let v = UIView()
        v.backgroundColor = .accent
        return v
    }()
    private lazy var drawBar: UIView = {
        let view = UIView()
        view.backgroundColor = .textPrimary.withAlphaComponent(0.15)
        return view
    }()
    private lazy var awayBar: UIView = {
        let view = UIView()
        view.backgroundColor = .textPrimary.withAlphaComponent(0.35)
        return view
    }()

    private lazy var barStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [homeBar, drawBar, awayBar])
        s.axis = .horizontal
        s.spacing = 2
        s.layer.cornerRadius = Layout.barCornerRadius
        s.clipsToBounds = true
        return s
    }()

    private lazy var countsStack: UIStackView = {
        let homeStack = UIStackView(arrangedSubviews: [homeCountLabel, homeCaptionLabel])
        homeStack.axis = .vertical
        homeStack.alignment = .center

        let drawStack = UIStackView(arrangedSubviews: [drawCountLabel, drawCaptionLabel])
        drawStack.axis = .vertical
        drawStack.alignment = .center

        let awayStack = UIStackView(arrangedSubviews: [awayCountLabel, awayCaptionLabel])
        awayStack.axis = .vertical
        awayStack.alignment = .center

        let s = UIStackView(arrangedSubviews: [homeStack, drawStack, awayStack])
        s.axis = .horizontal
        s.distribution = .equalSpacing
        return s
    }()

    private var barConstraints: [NSLayoutConstraint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(countsStack, barStack)
        countsStack
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor)
        barStack
            .top(countsStack.bottomAnchor, AppLayout.smallSpacing.value).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor).0
            .height(Layout.barHeight)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(homeWins: Int, draws: Int, awayWins: Int) {
        homeCountLabel.text = "\(homeWins)"
        drawCountLabel.text = "\(draws)"
        awayCountLabel.text = "\(awayWins)"

        NSLayoutConstraint.deactivate(barConstraints)
        barConstraints.removeAll()

        let bars: [(view: UIView, value: Int)] = [(homeBar, homeWins), (drawBar, draws), (awayBar, awayWins)]
        bars.forEach { $0.view.isHidden = $0.value == 0 }

        let visible = bars.filter { $0.value > 0 }
        let total = visible.reduce(0) { $0 + $1.value }
        guard total > 0 else { return }

        // Sonuncu bar qalan yeri tutur; qalanlara nisbi en verilir (aralıq boşluğu çıxılır).
        let gaps = barStack.spacing * CGFloat(visible.count - 1)
        for item in visible.dropLast() {
            let fraction = CGFloat(item.value) / CGFloat(total)
            barConstraints.append(
                item.view.widthAnchor.constraint(
                    equalTo: barStack.widthAnchor,
                    multiplier: fraction,
                    constant: -gaps * fraction
                )
            )
        }
        NSLayoutConstraint.activate(barConstraints)
    }

    private func countLabel() -> UILabel {
        let l = UILabel()
        l.font = AppFonts.titleBold.font
        l.textColor = .titleColor
        return l
    }

    private func captionLabel(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = AppFonts.litletitle.font
        l.textColor = .labelColor
        return l
    }
}
