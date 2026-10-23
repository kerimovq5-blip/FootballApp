//
//  UIViewController+MatchAlerts.swift
//  FootballApp
//
//  Zəng düyməsi bir neçə ekranda var (Home, Axtarış); nəticəni eyni cür göstərmək üçün.
//

import UIKit

extension UIViewController {

    /// Oyunu izləyir və ya izləməni dayandırır. `completion` zəngin yeni vəziyyətini verir.
    func toggleMatchAlert(_ match: Match,
                          competition: String,
                          using alerts: MatchAlertsUseCase,
                          completion: @escaping (_ isFollowing: Bool) -> Void) {
        Task { [weak self] in
            let result = await alerts.toggle(match, competition: competition)
            switch result {
            case .unfollowed:
                completion(false)
            case .followed:
                completion(true)
            case .permissionDenied:
                completion(true)
                self?.showNotificationsDeniedAlert()
            }
        }
    }

    /// İcazə verilməyibsə istifadəçini telefonun Settings-inə yönləndirir.
    func showNotificationsDeniedAlert() {
        let alert = UIAlertController(
            title: "Notifications are off",
            message: "Allow notifications for FootballApp in Settings to get a reminder before kick-off.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Not now", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
            UIApplication.shared.open(url)
        })
        present(alert, animated: true)
    }
}
