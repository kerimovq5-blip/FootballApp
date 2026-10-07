//
//  LineUpView.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 30.09.26.
//

import UIKit

final class LineUpView: UIView {

    struct Player {
        let number: Int
        let name: String
    }

    typealias Formation = [[Player]]

    private enum Layout {
        static let pitchCornerRadius: CGFloat = 16
        static let dotSize: CGFloat = 32
    }

    private lazy var formationLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.semiBold.font
        l.textColor = .titleColor
        l.textAlignment = .center
        return l
    }()

    private lazy var pitchView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.green
        v.layer.cornerRadius = Layout.pitchCornerRadius
        v.clipsToBounds = true
        return v
    }()

    private lazy var rowsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.distribution = .equalSpacing
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(formationLabel, pitchView)
        pitchView.addSubviews(rowsStack)

        formationLabel
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor)

        pitchView
            .top(formationLabel.bottomAnchor, AppLayout.smallSpacing.value).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor).0
            .height(360)

        rowsStack
            .top(pitchView.topAnchor, AppLayout.smallSpacing.value).0
            .leading(pitchView.leadingAnchor, AppLayout.smallSpacing.value).0
            .trailing(pitchView.trailingAnchor, -AppLayout.smallSpacing.value).0
            .bottom(pitchView.bottomAnchor, -AppLayout.smallSpacing.value)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(formationName: String, formation: Formation) {
        formationLabel.text = "Formation (\(formationName))"

        rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for row in formation.reversed() {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .equalSpacing
            rowStack.alignment = .center

            for player in row {
                rowStack.addArrangedSubview(makePlayerDot(player))
            }

            let wrapper = UIStackView(arrangedSubviews: [UIView(), rowStack, UIView()])
            wrapper.axis = .horizontal
            wrapper.distribution = .equalCentering
            rowsStack.addArrangedSubview(wrapper)
        }
    }

    private func makePlayerDot(_ player: Player) -> UIView {
        let circle = UIView()
        circle.backgroundColor = .accent
        circle.layer.cornerRadius = Layout.dotSize / 2
        circle.width(Layout.dotSize).0.height(Layout.dotSize)

        let numberLabel = UILabel()
        numberLabel.text = "\(player.number)"
        numberLabel.font = AppFonts.mediumTitle.font
        numberLabel.textColor = .buttonTitlecolor
        numberLabel.textAlignment = .center
        circle.addSubviews(numberLabel)
        numberLabel
            .centerX(circle.centerXAnchor).0
            .centerY(circle.centerYAnchor)

        let nameLabel = UILabel()
        nameLabel.text = player.name
        nameLabel.font = AppFonts.litletitle.font
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [circle, nameLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }
}
