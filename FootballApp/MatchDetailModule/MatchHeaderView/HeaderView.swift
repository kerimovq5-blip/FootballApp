import UIKit

/// Komanda loqoları tünd dairələrdə, ortada böyük hesab, onun altında dəqiqə / status.
final class MatchHeaderView: UIView {

    private enum Layout {
        static let crestCircleSize: CGFloat = 76
        static let crestInset: CGFloat = 14
        static let maxSideWidthMultiplier: CGFloat = 0.34
    }

    private let homeCrest = CrestCircleView(size: Layout.crestCircleSize, inset: Layout.crestInset)
    private let awayCrest = CrestCircleView(size: Layout.crestCircleSize, inset: Layout.crestInset)

    private lazy var homeNameLabel = teamNameLabel()
    private lazy var awayNameLabel = teamNameLabel()

    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var minuteLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.regularBody.font
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        return label
    }()

    private lazy var homeStack = makeTeamStack(crest: homeCrest, nameLabel: homeNameLabel)
    private lazy var awayStack = makeTeamStack(crest: awayCrest, nameLabel: awayNameLabel)

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(homeStack, awayStack, scoreLabel, minuteLabel)

        homeStack
            .leading(leadingAnchor).0
            .top(topAnchor).0
            .bottom(bottomAnchor)

        awayStack
            .trailing(trailingAnchor).0
            .top(topAnchor).0
            .bottom(bottomAnchor)

        // Hesab loqonun mərkəzi ilə, dəqiqə isə komanda adı ilə eyni xətdə dayanır.
        scoreLabel
            .centerX(centerXAnchor).0
            .centerY(homeCrest.centerYAnchor)

        minuteLabel
            .centerX(centerXAnchor).0
            .centerY(homeNameLabel.centerYAnchor)

        [homeStack, awayStack].forEach {
            $0.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: Layout.maxSideWidthMultiplier).isActive = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        homeName: String,
        awayName: String,
        homeCrest: UIImage?,
        awayCrest: UIImage?,
        score: String,
        minuteOrStatus: String
    ) {
        homeNameLabel.text = homeName
        awayNameLabel.text = awayName
        self.homeCrest.configure(image: homeCrest, fallbackName: homeName)
        self.awayCrest.configure(image: awayCrest, fallbackName: awayName)
        scoreLabel.text = score
        minuteLabel.text = minuteOrStatus
    }

    // MARK: - Private

    private func makeTeamStack(crest: UIView, nameLabel: UILabel) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [crest, nameLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }

    private func teamNameLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }
}

/// Tünd dairə içində loqo; loqo yoxdursa komandanın baş hərfləri göstərilir.
private final class CrestCircleView: UIView {

    private let imageView = UIImageView()
    private let initialsLabel = UILabel()

    init(size: CGFloat, inset: CGFloat) {
        super.init(frame: .zero)
        backgroundColor = AssetColors.backgroundColor2.color
        layer.cornerRadius = size / 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor

        imageView.contentMode = .scaleAspectFit
        initialsLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        initialsLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        initialsLabel.textAlignment = .center

        addSubviews(imageView, initialsLabel)
        width(size).0.height(size)

        imageView
            .top(topAnchor, inset).0
            .bottom(bottomAnchor, -inset).0
            .leading(leadingAnchor, inset).0
            .trailing(trailingAnchor, -inset)

        initialsLabel
            .centerX(centerXAnchor).0
            .centerY(centerYAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(image: UIImage?, fallbackName: String) {
        imageView.image = image
        imageView.isHidden = image == nil
        initialsLabel.text = String(fallbackName.prefix(3)).uppercased()
        initialsLabel.isHidden = image != nil
    }
}
