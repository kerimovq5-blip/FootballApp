//
//  ProfileSettingView.swift
//  FootballApp
//
//  Created by Servan on 08.10.26.
//

import UIKit

final class ProfileSettingsView: UIView {

    var onClearActivity: (() -> Void)?
    /// "Match reminders" açarı dəyişəndə (icazəni ekran soruşur).
    var onRemindersToggled: ((Bool) -> Void)?

    private let settings: SettingsStoring

    private lazy var notificationsRow = ProfileInfoRow(
        icon: "bell",
        title: "Match reminders",
        value: "\(MatchAlertsUseCase.minutesBefore) min before kick-off of followed matches",
        accessory: .toggle
    )

    private lazy var clearActivityRow = ProfileInfoRow(
        icon: "trash",
        title: "Clear activity",
        value: "Remove recently viewed matches",
        accessory: .chevron
    )

    private lazy var versionRow = ProfileInfoRow(
        icon: "info.circle",
        title: "App version",
        value: ProfileSettingsView.versionText
    )

    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [notificationsRow, clearActivityRow, versionRow])
        stack.axis = .vertical
        return stack
    }()

    init(settings: SettingsStoring) {
        self.settings = settings
        super.init(frame: .zero)

        addSubviews(stack)
        stack
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor)

        notificationsRow.setToggle(isOn: settings.notificationsEnabled)
        notificationsRow.onToggle = { [weak self] isOn in
            self?.onRemindersToggled?(isOn)
        }
        clearActivityRow.onTap = { [weak self] in
            self?.onClearActivity?()
        }
    }

    /// İcazə verilməyəndə açarı geri qaytarmaq üçün.
    func setRemindersOn(_ isOn: Bool) {
        notificationsRow.setToggle(isOn: isOn)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static var versionText: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
