//
//  ProfileActivityView.swift
//  FootballApp
//
//  Created by Servan on 08.10.26.
//

import UIKit

/// Son baxılan oyunlar. Boşdursa izahat yazısı göstərir.
final class ProfileActivityView: UIView {

    var onSelectMatch: ((Int) -> Void)?

    private let store: ActivityStoring

    private static let timeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()

    private let rowsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.regularBody.font
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "No activity yet.\nMatches you open will show up here."
        return label
    }()

    private lazy var rootStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [rowsStack, emptyLabel])
        stack.axis = .vertical
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        return stack
    }()

    init(store: ActivityStoring) {
        self.store = store
        super.init(frame: .zero)
        addSubviews(rootStack)
        rootStack
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor)
        reload()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reload() {
        rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let items = store.recent()
        for item in items {
            let time = ProfileActivityView.timeFormatter.localizedString(for: item.date, relativeTo: Date())
            let row = ProfileInfoRow(
                icon: "clock",
                title: item.title,
                value: "\(item.subtitle) · \(time)",
                accessory: .chevron
            )
            row.onTap = { [weak self] in
                self?.onSelectMatch?(item.matchID)
            }
            rowsStack.addArrangedSubview(row)
        }

        rowsStack.isHidden = items.isEmpty
        emptyLabel.isHidden = !items.isEmpty
    }
}
