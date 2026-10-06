//
//  MatchFilterCell.swift
//  FootballApp
//
//  Created by Servan on 29.09.26.
//

import UIKit

final class MatchFilterCell: UICollectionViewCell {

    static let reuseID = "MatchFilterCell"

    var onFilterChanged: ((MatchFilter) -> Void)?

    private var buttons: [UIButton] = []
    private var selectedFilter: MatchFilter = .all {
        didSet { updateAppearance() }
    }

    private lazy var stack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 10
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHierarchy() {
        contentView.addSubviews(stack)
        stack
            .leading(contentView.leadingAnchor).0
            .top(contentView.topAnchor).0
            .bottom(contentView.bottomAnchor)
            
            
            for (index, filter) in MatchFilter.allCases.enumerated() {
                let button = UIButton(type: .system)
                button.setTitle(filter.title, for: .normal)
                button.titleLabel?.font = AppFonts.semiBold.font
                button.layer.cornerRadius = 18
                button.contentEdgeInsets = UIEdgeInsets(
                    top: 8,
                    left: 18,
                    bottom: 8,
                    right: 18
                )
                button.tag = index
                button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
                buttons.append(button)
                stack.addArrangedSubview(button)
            }
        
        updateAppearance()
    }

    @objc private func tapped(_ sender: UIButton) {
        let filter = MatchFilter.allCases[sender.tag]
        selectedFilter = filter
        onFilterChanged?(filter)
    }

    private func updateAppearance() {
        for (index, button) in buttons.enumerated() {
            let isSelected = MatchFilter.allCases[index] == selectedFilter
            button.backgroundColor = isSelected ? .white : UIColor.white.withAlphaComponent(0.12)
            button.setTitleColor(isSelected ? .black : .white, for: .normal)
        }
    }

    func configure(selected: MatchFilter) {
        self.selectedFilter = selected
    }
}
