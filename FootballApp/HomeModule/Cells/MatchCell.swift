//
//  MatchCell.swift
//  FootballApp
//
//  Created by Servan on 29.09.26.
//

import UIKit

final class MatchCell: UICollectionViewCell {

    static let reuseID = "MatchCell"

    /// Zəng düyməsinə toxunanda çağırılır; vəziyyəti dəyişmək controller-in işidir.
    var onBellTapped: (() -> Void)?

    private static let bellSymbolConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)

    private lazy var homeLabel = teamLabel()
    private lazy var awayLabel = teamLabel()

    private lazy var teamsStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [homeLabel, awayLabel])
        s.axis = .vertical
        s.spacing = 6
        return s
    }()

    private lazy var scoreLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.titleBold.font
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private lazy var statusLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.semiBold.font
        l.textAlignment = .center
        return l
    }()

    private lazy var bellButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(bellTapped), for: .touchUpInside)
        return button
    }()

    private lazy var container: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 14
        return v
    }()

    private lazy var rowStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [teamsStack, scoreLabel, statusLabel, bellButton])
        s.axis = .horizontal
        s.alignment = .center
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 8)
        s.spacing = 10
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        scoreLabel.setContentHuggingPriority(.required, for: .horizontal)
        statusLabel.width(60)
        bellButton.width(36).0.height(36)

        contentView.addSubviews(container)
        container.addSubviews(rowStack)

        container
            .top(contentView.topAnchor).0
            .leading(contentView.leadingAnchor).0
            .trailing(contentView.trailingAnchor).0
            .bottom(contentView.bottomAnchor)

        rowStack
            .top(container.topAnchor).0
            .leading(container.leadingAnchor).0
            .trailing(container.trailingAnchor).0
            .bottom(container.bottomAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onBellTapped = nil
    }

    private func teamLabel() -> UILabel {
        let l = UILabel()
        l.font = AppFonts.mediumTitle.font
        l.textColor = .white
        return l
    }

    func configure(with match: Match, isSubscribed: Bool) {
        homeLabel.text = match.home
        awayLabel.text = match.away
        statusLabel.text = match.status.displayText
        statusLabel.textColor = match.status.isLive ? .systemGreen : UIColor.white.withAlphaComponent(0.6)

        if let home = match.homeScore, let away = match.awayScore {
            scoreLabel.text = "\(home) - \(away)"
        } else {
            scoreLabel.text = ""
        }

        // Bitmiş oyunun bildirişi mənasızdır: düymə görünmür, amma sətrin yerləşməsi dəyişmir.
        var isFinished = false
        if case .finished = match.status { isFinished = true }
        bellButton.alpha = isFinished ? 0 : 1
        bellButton.isEnabled = !isFinished
        setSubscribed(isSubscribed, animated: false)
    }

    func setSubscribed(_ isSubscribed: Bool, animated: Bool) {
        let symbol = isSubscribed ? "bell.fill" : "bell"
        bellButton.setImage(UIImage(systemName: symbol, withConfiguration: MatchCell.bellSymbolConfig), for: .normal)
        bellButton.tintColor = isSubscribed ? AppGradient.accentStart : UIColor.white.withAlphaComponent(0.5)
        bellButton.accessibilityLabel = isSubscribed ? "Turn off notifications" : "Turn on notifications"

        guard animated else { return }
        bellButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.45,
                       initialSpringVelocity: 8, options: []) {
            self.bellButton.transform = .identity
        }
    }

    @objc private func bellTapped() {
        onBellTapped?()
    }
}
