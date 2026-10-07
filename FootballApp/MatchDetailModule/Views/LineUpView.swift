import UIKit

final class LineUpView: UIView {

    private enum Layout {
        /// Dizayndakı meydançanın hündürlük / en nisbəti.
        static let pitchAspectRatio: CGFloat = 1.134
        static let sectionSpacing: CGFloat = 20
    }

    private var lineups: MatchLineups?

    private lazy var predictedBanner: UIView = {
        let icon = UIImageView(image: UIImage(systemName: "info.circle"))
        icon.tintColor = AppGradient.accentStart
        icon.contentMode = .scaleAspectFit
        icon.width(18).0.height(18)

        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.text = "Predicted line-up. The official starting XI is usually announced about an hour before kick-off."

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        stack.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        stack.layer.cornerRadius = 14
        return stack
    }()

    private lazy var formationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private let teamTabsContainer = UIView()
    private let pitchView = PitchView()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [predictedBanner, formationLabel, teamTabsContainer, pitchView])
        stack.axis = .vertical
        stack.spacing = Layout.sectionSpacing
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(contentStack)
        contentStack
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor)

        pitchView.height(pitchView.widthAnchor, multiplier: Layout.pitchAspectRatio)
        predictedBanner.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func configure(with lineups: MatchLineups) {
        self.lineups = lineups
        predictedBanner.isHidden = lineups.isConfirmed
        rebuildTeamTabs(for: lineups)
        showTeam(at: 0, animated: false)
    }

    // MARK: - Private

    private func rebuildTeamTabs(for lineups: MatchLineups) {
        teamTabsContainer.subviews.forEach { $0.removeFromSuperview() }

        let tabs = PillTabBar(titles: [lineups.home.teamName, lineups.away.teamName], alignment: .leading)
        tabs.onSelect = { [weak self] index in
            self?.showTeam(at: index, animated: true)
        }
        teamTabsContainer.addSubviews(tabs)
        tabs
            .top(teamTabsContainer.topAnchor).0
            .leading(teamTabsContainer.leadingAnchor).0
            .trailing(teamTabsContainer.trailingAnchor).0
            .bottom(teamTabsContainer.bottomAnchor)
    }

    private func showTeam(at index: Int, animated: Bool) {
        guard let lineups else { return }
        let team = index == 0 ? lineups.home : lineups.away
        formationLabel.attributedText = makeFormationText(team.formation)

        let apply: () -> Void = { [weak self] in
            self?.pitchView.configure(lineup: team, isPredicted: !lineups.isConfirmed)
        }
        if animated {
            UIView.transition(with: pitchView, duration: 0.25, options: .transitionCrossDissolve, animations: apply)
        } else {
            apply()
        }
    }

    private func makeFormationText(_ formation: String) -> NSAttributedString {
        let text = NSMutableAttributedString(
            string: "Formation",
            attributes: [
                .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
        )
        text.append(NSAttributedString(
            string: "   (\(formation))",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.white.withAlphaComponent(0.6)
            ]
        ))
        return text
    }
}
