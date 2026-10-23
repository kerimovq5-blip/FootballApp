//
//  APIFootballMapper+Home.swift
//  FootballApp
//
//  Günün oyunları → liqalara görə qruplaşdırılmış `League` siyahısı.
//

import Foundation

extension APIFootballMapper {

    // MARK: - Home

    static func leagues(from fixtures: [FixtureDTO], allowedIDs: [Int]) -> [League] {
        let grouped = Dictionary(grouping: fixtures, by: { $0.league.id })

        // Əsas liqalar öndə, qalanları oyun sayına görə (çoxdan aza) arxada.
        let rest = grouped.keys
            .filter { !allowedIDs.contains($0) }
            .sorted {
                let left = grouped[$0]?.count ?? 0
                let right = grouped[$1]?.count ?? 0
                return left != right ? left > right : $0 < $1
            }
        let orderedIDs = allowedIDs + rest.prefix(15)   // 15: "qalan" liqaların maksimum sayı

        return orderedIDs.compactMap { id in
            guard let items = grouped[id], let first = items.first else { return nil }
            let matches = items
                .sorted { $0.fixture.date < $1.fixture.date }
                .map(mapMatch)
            return League(id: id,
                          name: first.league.name,
                          country: first.league.country ?? "",
                          flag: flag(for: first.league),
                          matches: matches)
        }
    }
}
