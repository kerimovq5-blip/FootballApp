//
//  HomeStateCell.swift
//  FootballApp
//

import UIKit

/// Home-da oyunların yerində göstərilir: yüklənir və ya xəta + "Try again".
/// Gün seçicisi və filtr yuxarıda görünməyə davam edir.
final class HomeStateCell: UICollectionViewCell {

    static let reuseID = "HomeStateCell"

    private let stateView = StateView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        stateView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stateView)
        NSLayoutConstraint.activate([
            stateView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureLoading() {
        stateView.onRetry = nil
        stateView.showLoading()
    }

    func configure(error: UserFacingError, onRetry: @escaping () -> Void) {
        stateView.onRetry = onRetry
        stateView.show(error)
    }
}
