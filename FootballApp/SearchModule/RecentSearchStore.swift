//
//  RecentSearchStoring.swift
//  FootballApp
//
//  Created by Servan on 10.10.26.
//


//
//  RecentSearchStore.swift
//  FootballApp
//

import Foundation

protocol RecentSearchStoring: AnyObject {
    /// Ən yenisi birinci.
    var items: [String] { get }
    func add(_ query: String)
    func clear()
}

/// Son axtarışlar (ən çox 8 dənə, təkrar olmadan).
final class UserDefaultsRecentSearchStore: RecentSearchStoring {

    static let shared = UserDefaultsRecentSearchStore()

    private let key = "search.recentQueries"
    private let limit = 8
    private let defaults = UserDefaults.standard

    private init() {}

    var items: [String] {
        defaults.stringArray(forKey: key) ?? []
    }

    func add(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var list = items.filter { $0.caseInsensitiveCompare(trimmed) != .orderedSame }
        list.insert(trimmed, at: 0)
        defaults.set(Array(list.prefix(limit)), forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}