//
//  AvatarImageView.swift
//  FootballApp
//
//  Created by Servan on 05.10.26.
//



import UIKit

/// Dairəvi profil şəkli. Şəkil yoxdursa, mərkəzdə sadə person ikonu göstərir.
final class AvatarImageView: UIImageView {

    init(size: CGFloat) {
        super.init(frame: .zero)
        clipsToBounds = true
        backgroundColor = AssetColors.backgroundColor2.color
        layer.cornerRadius = size / 2
        isUserInteractionEnabled = true
        setAvatar(nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setAvatar(_ photo: UIImage?) {
        if let photo {
            image = photo
            contentMode = .scaleAspectFill
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: layer.cornerRadius, weight: .regular)
            image = UIImage(systemName: "person.fill", withConfiguration: config)
            tintColor = UIColor.white.withAlphaComponent(0.7)
            contentMode = .center
        }
    }
}
