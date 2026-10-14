//
//  HomeEmptyCell.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//


//
//  HomeEmptyCell.swift
//  FootballApp
//

import UIKit

/// Seçilmiş gün və filtr üçün oyun olmayanda göstərilən mesaj.
final class HomeEmptyCell: UICollectionViewCell {

    static let reuseID = "HomeEmptyCell"

    private let label: UILabel = {
        let label = UILabel()
        label.font = AppFonts.regularBody.font
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubviews(label)
        label
            .leading(contentView.leadingAnchor).0
            .trailing(contentView.trailingAnchor).0
            .centerY(contentView.centerYAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(message: String) {
        label.text = message
    }
}