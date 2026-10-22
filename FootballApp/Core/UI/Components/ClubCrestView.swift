//
//  ClubCrestView.swift
//  FootballApp
//
//  Created by Servan on 11.10.26.
//

//
//  ClubCrestView.swift
//  FootballApp
//

import UIKit

final class ClubCrestView: UIView {

    private let imageView = UIImageView()
    private let initialsLabel = UILabel()
    /// Gec gələn şəkil başqa məzmunun üstünə yazılmasın deyə son istənən URL.
    private var imageURL: String?

    init(size: CGFloat, inset: CGFloat) {
        super.init(frame: .zero)
        backgroundColor = AssetColors.backgroundColor2.color
        layer.cornerRadius = size / 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor

        imageView.contentMode = .scaleAspectFit
        initialsLabel.font = UIFont.systemFont(ofSize: size * 0.24, weight: .bold)
        initialsLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        initialsLabel.textAlignment = .center

        addSubviews(imageView, initialsLabel)
        width(size).0.height(size)

        imageView
            .top(topAnchor, inset).0
            .bottom(bottomAnchor, -inset).0
            .leading(leadingAnchor, inset).0
            .trailing(trailingAnchor, -inset)

        initialsLabel
            .centerX(centerXAnchor).0
            .centerY(centerYAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(initials: String) {
        configure(initials: initials, imageURL: nil)
    }

    /// Şəkil yüklənənə qədər (və ya yüklənməsə) baş hərflər görünür.
    func configure(initials: String, imageURL: String?) {
        self.imageURL = imageURL
        imageView.image = nil
        imageView.isHidden = true
        initialsLabel.text = initials
        initialsLabel.isHidden = false

        guard let imageURL else { return }
        ImageLoader.shared.load(imageURL) { [weak self] image in
            guard let self, let image, self.imageURL == imageURL else { return }
            self.imageView.image = image
            self.imageView.isHidden = false
            self.initialsLabel.isHidden = true
        }
    }
}
