//
//  PitchView.swift
//  FootballApp
//
//  Created by Servan on 07.10.26.
//

import UIKit

/// Zolaqlı yaşıl meydança: yarımmüdafiə xətti, mərkəz dairəsi, cərimə meydançası və künc qövsləri çəkilir,
/// oyunçular normallaşdırılmış koordinatlara görə yerləşdirilir.
final class PitchView: UIView {

    private enum Layout {
        static let cornerRadius: CGFloat = 16
        static let stripeCount = 8
        static let lineWidth: CGFloat = 1.2
        static let halfwayRatio: CGFloat = 0.05
        static let centerCircleRatio: CGFloat = 0.156
        static let penaltyBoxWidthRatio: CGFloat = 0.457
        static let penaltyBoxHeightRatio: CGFloat = 0.169
        static let goalBoxWidthRatio: CGFloat = 0.245
        static let goalBoxHeightRatio: CGFloat = 0.099
        static let cornerArcRadius: CGFloat = 14
    }

    private enum Palette {
        static let lightStripe = UIColor(red: 0.54, green: 0.80, blue: 0.62, alpha: 1)
        static let darkStripe = UIColor(red: 0.40, green: 0.67, blue: 0.56, alpha: 1)
        static let line = UIColor.white.withAlphaComponent(0.9)
    }

    private var nodes: [(node: PlayerNodeView, slot: PitchSlot)] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Palette.lightStripe
        layer.cornerRadius = Layout.cornerRadius
        clipsToBounds = true
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func configure(lineup: TeamLineup, isPredicted: Bool) {
        nodes.forEach { $0.node.removeFromSuperview() }
        nodes = FormationLayout.slots(for: lineup).map { slot in
            let node = PlayerNodeView()
            node.configure(player: slot.player, isPredicted: isPredicted)
            addSubview(node)
            return (node, slot)
        }
        setNeedsLayout()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        for (node, slot) in nodes {
            let maxPillWidth = min(84, bounds.width / CGFloat(max(slot.lineSize, 3)) - 6)
            node.setMaxNameWidth(maxPillWidth)

            let size = node.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            let centerX = slot.x * bounds.width
            let circleCenterY = slot.y * bounds.height
            node.frame = CGRect(
                x: centerX - size.width / 2,
                y: circleCenterY - PlayerNodeView.circleSize / 2,
                width: size.width,
                height: size.height
            )
        }
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        let width = bounds.width
        let height = bounds.height
        guard width > 0, height > 0, let context = UIGraphicsGetCurrentContext() else { return }

        let stripeHeight = height / CGFloat(Layout.stripeCount)
        for index in 0..<Layout.stripeCount {
            (index % 2 == 0 ? Palette.darkStripe : Palette.lightStripe).setFill()
            context.fill(CGRect(x: 0, y: CGFloat(index) * stripeHeight, width: width, height: stripeHeight + 0.5))
        }

        let path = UIBezierPath()
        path.lineWidth = Layout.lineWidth
        Palette.line.setStroke()

        // Yarımmüdafiə xətti və mərkəz dairəsi.
        let halfwayY = height * Layout.halfwayRatio
        path.move(to: CGPoint(x: 0, y: halfwayY))
        path.addLine(to: CGPoint(x: width, y: halfwayY))

        let radius = width * Layout.centerCircleRatio
        path.move(to: CGPoint(x: width / 2 + radius, y: halfwayY))
        path.addArc(withCenter: CGPoint(x: width / 2, y: halfwayY), radius: radius,
                    startAngle: 0, endAngle: .pi * 2, clockwise: true)

        // Yan və alt xətlər (üst tərəf açıq qalır, çünki meydançanın yalnız bir hissəsi göstərilir).
        let edge: CGFloat = 1
        path.move(to: CGPoint(x: edge, y: 0))
        path.addLine(to: CGPoint(x: edge, y: height - edge))
        path.addLine(to: CGPoint(x: width - edge, y: height - edge))
        path.addLine(to: CGPoint(x: width - edge, y: 0))

        // Cərimə və qapı meydançaları.
        let penaltyWidth = width * Layout.penaltyBoxWidthRatio
        let penaltyHeight = height * Layout.penaltyBoxHeightRatio
        path.append(UIBezierPath(rect: CGRect(
            x: (width - penaltyWidth) / 2,
            y: height - penaltyHeight - edge,
            width: penaltyWidth,
            height: penaltyHeight
        )))

        let goalWidth = width * Layout.goalBoxWidthRatio
        let goalHeight = height * Layout.goalBoxHeightRatio
        path.append(UIBezierPath(rect: CGRect(
            x: (width - goalWidth) / 2,
            y: height - goalHeight - edge,
            width: goalWidth,
            height: goalHeight
        )))

        // Alt künc qövsləri.
        let arc = Layout.cornerArcRadius
        path.move(to: CGPoint(x: edge, y: height - arc))
        path.addArc(withCenter: CGPoint(x: edge, y: height - edge), radius: arc - edge,
                    startAngle: -.pi / 2, endAngle: 0, clockwise: true)
        path.move(to: CGPoint(x: width - arc, y: height - edge))
        path.addArc(withCenter: CGPoint(x: width - edge, y: height - edge), radius: arc - edge,
                    startAngle: .pi, endAngle: 3 * .pi / 2, clockwise: true)

        path.stroke()
    }
}
