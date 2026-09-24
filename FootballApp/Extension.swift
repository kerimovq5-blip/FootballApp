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
