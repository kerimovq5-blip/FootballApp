//
//  MatchEventView.swift
//  FootballApp
//
//  Created by Servan on 07.10.26.
//
import UIKit

/// Ortadakı şaquli xətt boyunca dəqiqələrə görə hadisələr: ev sahibi solda, qonaq sağda.
final class MatchEventsView: UIView {

    private let timelineStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return view
    }()

    private lazy var timelineContainer: UIView = {
        let container = UIView()
        container.addSubviews(lineView, timelineStack)
        timelineStack
            .top(container.topAnchor).0
            .leading(container.leadingAnchor).0
            .trailing(container.trailingAnchor).0
            .bottom(container.bottomAnchor)
        lineView
            .centerX(container.centerXAnchor).0
            .top(timelineStack.topAnchor).0
            .bottom(timelineStack.bottomAnchor).0
            .width(1)
        return container
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.regularBody.font
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var rootStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timelineContainer, emptyLabel])
        stack.axis = .vertical
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(rootStack)
        rootStack
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(events: [MatchEvent], hasStarted: Bool) {
        timelineStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        events.forEach { timelineStack.addArrangedSubview(MatchEventRow(event: $0)) }

        timelineContainer.isHidden = events.isEmpty
        emptyLabel.isHidden = !events.isEmpty
        emptyLabel.text = hasStarted
            ? "No key events yet."
            : "The match hasn't started yet. Key events will appear here."
    }
}

// MARK: - Row

private final class MatchEventRow: UIView {

    private enum Layout {
        static let badgeMinWidth: CGFloat = 46
        static let gap: CGFloat = 12
        static let verticalPadding: CGFloat = 8
    }

    init(event: MatchEvent) {
        super.init(frame: .zero)
        if event.kind == .halfTime {
            buildHalfTime(event)
        } else {
            buildEvent(event)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildHalfTime(_ event: MatchEvent) {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.text = "Half Time  ·  \(event.detail ?? "")"

        let chip = UIView()
        chip.backgroundColor = AssetColors.backgroundColor2.color
        chip.layer.cornerRadius = 13
        chip.addSubviews(label)
        label
            .top(chip.topAnchor, 6).0
            .bottom(chip.bottomAnchor, -6).0
            .leading(chip.leadingAnchor, 14).0
            .trailing(chip.trailingAnchor, -14)

        addSubviews(chip)
        chip
            .centerX(centerXAnchor).0
            .top(topAnchor, 6).0
            .bottom(bottomAnchor, -6)
    }

    private func buildEvent(_ event: MatchEvent) {
        let minuteLabel = UILabel()
        minuteLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        minuteLabel.textColor = .white
        minuteLabel.textAlignment = .center
        minuteLabel.text = event.minute

        // Badge-in fonu tam örtücüdür, ona görə ortadakı xətt dəqiqənin arxasında görünmür.
        let badge = UIView()
        badge.backgroundColor = AssetColors.backgroundColor2.color
        badge.layer.cornerRadius = 12
        badge.addSubviews(minuteLabel)
        minuteLabel
            .top(badge.topAnchor, 4).0
            .bottom(badge.bottomAnchor, -4).0
            .leading(badge.leadingAnchor, 8).0
            .trailing(badge.trailingAnchor, -8)

        let content = makeContent(for: event)
        addSubviews(badge, content)

        badge
            .centerX(centerXAnchor).0
            .centerY(centerYAnchor)
        badge.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.badgeMinWidth).isActive = true

        content
            .top(topAnchor, Layout.verticalPadding).0
            .bottom(bottomAnchor, -Layout.verticalPadding)

        switch event.side {
        case .home:
            content.trailing(badge.leadingAnchor, -Layout.gap)
            content.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
        case .away:
            content.leading(badge.trailingAnchor, Layout.gap)
            content.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
        }
    }

    private func makeContent(for event: MatchEvent) -> UIStackView {
        let isHome = event.side == .home
        let textAlignment: NSTextAlignment = isHome ? .right : .left

        let playerLabel = UILabel()
        playerLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        playerLabel.textColor = .white
        playerLabel.numberOfLines = 0
        playerLabel.textAlignment = textAlignment
        playerLabel.text = event.player

        let subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = textAlignment
        subtitleLabel.text = [event.kind.title, event.detail].compactMap { $0 }.joined(separator: " · ")

        let textStack = UIStackView(arrangedSubviews: [playerLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = isHome ? .trailing : .leading

        let iconLabel = UILabel()
        iconLabel.text = event.kind.icon
        iconLabel.font = UIFont.systemFont(ofSize: 18)
        iconLabel.setContentHuggingPriority(.required, for: .horizontal)
        iconLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let views: [UIView] = isHome ? [textStack, iconLabel] : [iconLabel, textStack]
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }
}
