//
//  LeagueHeaderView.swift
//  FootballApp
//
//  Created by Servan on 29.09.26.
//

import UIKit

final class LeagueHeaderView: UICollectionReusableView {

    static let reuseID = "LeagueHeaderView"

    var onTap: (() -> Void)?
    
    private lazy var flagLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.titleBold.font
        return l
    }()

    private lazy var nameLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.semiBold.font
        l.textColor = .white
        return l
    }()

    private lazy var countryLabel: UILabel = {
        let l = UILabel()
        l.font = AppFonts.regularBody.font
        l.textColor = UIColor.white.withAlphaComponent(0.6)
        return l
    }()

    private lazy var textStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [nameLabel, countryLabel])
        s.axis = .vertical
        s.spacing = 2
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(flagLabel, textStack)
        flagLabel
            .leading(leadingAnchor).0
            .top(topAnchor, 12).0
            .bottom(bottomAnchor, -8)
        textStack
            .leading(flagLabel.trailingAnchor, 10).0
            .centerY(flagLabel.centerYAnchor)
        
        isUserInteractionEnabled = true
                addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    @objc private func tapped() { onTap?() }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with league: League) {
        flagLabel.text = league.flag
        nameLabel.text = league.name
        countryLabel.text = league.country
    }
}
