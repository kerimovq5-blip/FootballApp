//
//  SearchSectionHeaderView.swift
//  FootballApp
//
//  Created by Servan on 10.10.26.
//


//
//  SearchSectionHeaderView.swift
//  FootballApp
//

import UIKit

final class SearchSectionHeaderView: UICollectionReusableView {

    static let reuseID = "SearchSectionHeaderView"

    var onAction: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.semiBold.font
        label.textColor = .white
        return label
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = AppFonts.regularBody.font
        button.setTitleColor(AppGradient.accentStart, for: .normal)
        button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(titleLabel, actionButton)

        titleLabel
            .leading(leadingAnchor).0
            .top(topAnchor, 12).0
            .bottom(bottomAnchor, -8)

        actionButton
            .trailing(trailingAnchor).0
            .centerY(titleLabel.centerYAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onAction = nil
    }

    func configure(title: String, actionTitle: String?) {
        titleLabel.text = title
        actionButton.setTitle(actionTitle, for: .normal)
        actionButton.isHidden = actionTitle == nil
    }

    @objc private func actionTapped() {
        onAction?()
    }
}