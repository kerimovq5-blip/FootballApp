//
//  DayPickerCell.swift
//  FootballApp
//
//  Created by Servan on 14.10.26.
//

//
//  DayPickerCell.swift
//  FootballApp
//

import UIKit

final class DayPickerCell: UICollectionViewCell {

    static let reuseID = "DayPickerCell"

    var onDayChanged: ((HomeDay) -> Void)?

    private var buttons: [UIButton] = []
    private var selectedDay: HomeDay = .today {
        didSet { updateAppearance() }
    }

    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
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

        for (index, day) in HomeDay.allCases.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(day.title, for: .normal)
            button.titleLabel?.font = .semiBold
            button.layer.cornerRadius = 18
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            button.tag = index
            button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            buttons.append(button)
            stack.addArrangedSubview(button)
        }
        updateAppearance()
    }

    @objc private func tapped(_ sender: UIButton) {
        let day = HomeDay.allCases[sender.tag]
        selectedDay = day
        onDayChanged?(day)
    }

    private func updateAppearance() {
        for (index, button) in buttons.enumerated() {
            let isSelected = HomeDay.allCases[index] == selectedDay
            button.backgroundColor = isSelected ? .white : UIColor.white.withAlphaComponent(0.12)
            button.setTitleColor(isSelected ? .black : .white, for: .normal)
        }
    }

    func configure(selected: HomeDay) {
        selectedDay = selected
    }
}
