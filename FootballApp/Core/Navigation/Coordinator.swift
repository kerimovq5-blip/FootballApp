//
//  Coordinator.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 23.09.26.
//

import Foundation
import UIKit

public protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

/// Öz UINavigationController-i olan coordinator (tab-lar üçün).
public protocol NavigationCoordinator: Coordinator {
    var navigationController: UINavigationController { get }
}
