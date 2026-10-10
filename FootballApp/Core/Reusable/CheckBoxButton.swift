//
//  CheckBoxButton.swift
//  FootballApp
//
//  Created by Servan on 10.10.26.
//

//
//  CheckboxButton.swift
//  FootballApp
//

import UIKit

/// Seçiləndə rənglənən və ✓ göstərən checkbox. Toxunanda özü dəyişir, vəziyyət `isSelected`-dədir.
final class CheckboxButton: UIButton {

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        layer.cornerRadius = 6
        tintColor = .white

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let checkmark = UIImage(systemName: "checkmark", withConfiguration: symbolConfig)?
            .withRenderingMode(.alwaysTemplate)
        setImage(checkmark, for: .selected)

        addAction(UIAction { [weak self] _ in
            self?.isSelected.toggle()
        }, for: .touchUpInside)
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Kiçik düyməyə toxunmaq asan olsun deyə toxunma sahəsi hər tərəfdən 10 pt böyüdülür.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -10, dy: -10).contains(point)
    }

    private func updateAppearance() {
        backgroundColor = isSelected ? .accent : .clear
        layer.borderColor = (isSelected ? UIColor.accent : UIColor.labelColor).cgColor
    }
}
