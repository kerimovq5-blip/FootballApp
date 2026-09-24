//
//  Coordinator.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 23.09.26.
//

import Foundation
import UIKit

public protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    var childCoordinators: [Coordinator] { get set }
    func start()
}
