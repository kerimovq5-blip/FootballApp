//
//  Extension.swift
//  FirstAPI
//
//  Created by Servan on 26.06.26.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach(addSubview)
    }
    
    @discardableResult
    func top(
        _ anchor: NSLayoutYAxisAnchor,
        _ constant: CGFloat = 0,
        _ isActive: Bool = true
    ) -> (UIView, NSLayoutConstraint) {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = topAnchor.constraint(
            equalTo: anchor,
            constant: constant
        )
        constraint.isActive = isActive
        return (self, constraint)
    }
    
    @discardableResult
    func bottom(
        _ anchor: NSLayoutYAxisAnchor,
        _ constant: CGFloat = 0,
        _ isActive: Bool = true
    ) -> (UIView, NSLayoutConstraint) {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = bottomAnchor.constraint(
            equalTo: anchor,
            constant: constant
        )
        constraint.isActive = isActive
        return (self, constraint)
    }
    
    @discardableResult
    func centerY(
        _ anchor: NSLayoutYAxisAnchor,
        _ constant: CGFloat = 0,
        _ isActive: Bool = true
    ) -> (UIView, NSLayoutConstraint) {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerYAnchor.constraint(
            equalTo: anchor,
            constant: constant
        )
        constraint.isActive = isActive
        return (self, constraint)
    }
    
    @discardableResult
    func leading(
        _ anchor: NSLayoutXAxisAnchor,
        _ constant: CGFloat = 0,
        _ isActive: Bool = true
    ) -> (UIView, NSLayoutConstraint) {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = leadingAnchor.constraint(
            equalTo: anchor,
            constant: constant
        )
        constraint.isActive = isActive
        return (self, constraint)
    }
    
    @discardableResult
    func trailing(
        _ anchor: NSLayoutXAxisAnchor,
        _ constant: CGFloat = 0,
        _ isActive: Bool = true
    ) -> (UIView, NSLayoutConstraint) {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = trailingAnchor.constraint(
            equalTo: anchor,
            constant: constant
        )
        constraint.isActive = isActive
        return (self, constraint)
    }
    
    @discardableResult
    func centerX(
        _ anchor: NSLayoutXAxisAnchor,
        _ constant: CGFloat = 0,
        _ isActive: Bool = true
    ) -> (UIView, NSLayoutConstraint) {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerXAnchor.constraint(
            equalTo: anchor,
            constant: constant
        )
        constraint.isActive = isActive
        return (self, constraint)
    }
    
    @discardableResult
    func width(
        _ anchor: NSLayoutDimension,
        _ constant: CGFloat = 0,
        multiplier: CGFloat = 1,
        _ isActive: Bool = true
    ) -> (UIView, NSLayoutConstraint) {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(
            equalTo: anchor,
            multiplier: multiplier,
            constant: constant
        )
        constraint.isActive = isActive
        return (self, constraint)
    }
    
    @discardableResult
    func height(
        _ anchor: NSLayoutDimension,
        _ constant: CGFloat = 0,
        multiplier: CGFloat = 1,
        _ isActive: Bool = true
    ) -> (UIView, NSLayoutConstraint) {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(
            equalTo: anchor,
            multiplier: multiplier,
            constant: constant
        )
        constraint.isActive = isActive
        return (self, constraint)
    }
    
    @discardableResult
    func width(
        _ constant: CGFloat = 0,
        _ isActive: Bool = true
    ) -> (UIView, NSLayoutConstraint) {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(
            equalToConstant: constant
        )
        constraint.isActive = isActive
        return (self, constraint)
    }
    
    @discardableResult
    func height(
        _ constant: CGFloat = 0,
        _ isActive: Bool = true
    ) -> (UIView, NSLayoutConstraint) {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(
            equalToConstant: constant
        )
        constraint.isActive = isActive
        return (self, constraint)
    }
}

extension UIViewController {
    func showAlert(title: String = "Error", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    /// Şifrə gizlidirsə "eye.slash", görünürsə "eye" göstərilir.
    /// Düymə öz vəziyyətini özü dəyişir; `action` yalnız sahənin `isSecureTextEntry`-sini çevirir.
    func makePasswordToggleButton(action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(AppIcon.hidePassword.image(), for: .normal)
        button.setImage(AppIcon.showPassword.image(), for: .selected)
        button.tintColor = AssetColors.labelColor.color
        button.accessibilityLabel = "Show password"
        button.addAction(UIAction { [weak button] _ in
            guard let button else { return }
            button.isSelected.toggle()
            button.accessibilityLabel = button.isSelected ? "Hide password" : "Show password"
        }, for: .touchUpInside)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
