//
//  MatchStatsView.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 30.09.26.
//

import UIKit

final class MatchStatsView: UIView {

    struct Stat {
        let title: String
        let homeValue: String
        let awayValue: String
    }

    private lazy var stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = AppLayout.smallSpacing.value
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(stack)
        stack
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with stats: [Stat]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stats.forEach { stat in
            stack.addArrangedSubview(makeRow(for: stat))
        }
    }

    private func makeRow(for stat: Stat) -> UIView {
        let homeLabel = valueLabel(text: stat.homeValue, alignment: .left)
        let titleLabel: UILabel = {
            let l = UILabel()
            l.text = stat.title
            l.font = AppFonts.regularBody.font
            l.textColor = .labelColor
            l.textAlignment = .center
            return l
        }()
        let awayLabel = valueLabel(text: stat.awayValue, alignment: .right)

        let row = UIStackView(arrangedSubviews: [homeLabel, titleLabel, awayLabel])
        row.axis = .horizontal
        row.distribution = .fillEqually
        return row
    }

    private func valueLabel(text: String, alignment: NSTextAlignment) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = AppFonts.semiBold.font
        l.textColor = .titleColor
        l.textAlignment = alignment
        return l
    }
}
