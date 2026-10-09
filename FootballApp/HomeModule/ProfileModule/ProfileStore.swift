//
//  ProfilStore.swift
//  FootballApp
//
//  Created by Servan on 08.10.26.
//

import UIKit

protocol ProfileStoring {
    func load(email: String) -> ProfileInfo?
    func save(_ profile: ProfileInfo)
    func clear()
}

struct UserDefaultsProfileStore: ProfileStoring {

    /// E-poçt saxlanmır: o, sessiyadan / serverdən gəlir.
    private struct Stored: Codable {
        let name: String
        let bio: String
        let phone: String
        let address: String
    }

    private let key = "profile.info"
    private let defaults = UserDefaults.standard

    private var avatarURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("profile-avatar.jpg")
    }

    func load(email: String) -> ProfileInfo? {
        guard let data = defaults.data(forKey: key),
              let stored = try? JSONDecoder().decode(Stored.self, from: data) else { return nil }

        let avatar = avatarURL
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap { UIImage(data: $0) }

        return ProfileInfo(
            name: stored.name,
            email: email,
            bio: stored.bio,
            avatar: avatar,
            phone: stored.phone,
            address: stored.address
        )
    }

    func save(_ profile: ProfileInfo) {
        let stored = Stored(name: profile.name, bio: profile.bio, phone: profile.phone, address: profile.address)
        if let data = try? JSONEncoder().encode(stored) {
            defaults.set(data, forKey: key)
        }

        guard let url = avatarURL else { return }
        if let avatar = profile.avatar, let jpeg = avatar.jpegData(compressionQuality: 0.85) {
            try? jpeg.write(to: url, options: .atomic)
        } else {
            try? FileManager.default.removeItem(at: url)
        }
    }

    func clear() {
        defaults.removeObject(forKey: key)
        if let url = avatarURL {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
