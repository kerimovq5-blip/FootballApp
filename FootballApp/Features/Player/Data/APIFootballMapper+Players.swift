//
//  APIFootballMapper+Players.swift
//  FootballApp
//
//  Oyunçu DTO-larından ekran modellərinə: Explore reytinqləri, oyunçu səhifəsi, axtarış.
//

import Foundation

extension APIFootballMapper {

    // MARK: - Explore: top scorers / assists

    static func topPlayers(from items: [PlayerStatsDTO], kind: TopPlayersKind) -> [RankingEntry] {
        items.enumerated().map { index, item in
            let stat = item.statistics.first
            let value: Int?
            switch kind {
            case .goals: value = stat?.goals?.total?.value
            case .assists: value = stat?.goals?.assists?.value
            }
            let name = item.player.name ?? "–"
            let club = stat?.team?.name
            return RankingEntry(rank: index + 1,
                                name: name,
                                subtitle: club,
                                imageURL: item.player.photo,
                                value: value.map { "\($0)" } ?? "–",
                                player: PlayerReference(name: name, clubName: club, id: item.player.id))
        }
    }

    // MARK: - Axtarış

    static func playerSearchResults(from items: [PlayerProfileDTO]) -> [PlayerSearchResult] {
        items.map { item in
            let player = item.player
            return PlayerSearchResult(
                reference: PlayerReference(name: player.name ?? "–", number: player.number, id: player.id),
                position: playerPosition(player.position),
                flag: CountryFlag.emoji(forCountryName: player.nationality) ?? "",
                nationality: player.nationality,
                photoURL: player.photo
            )
        }
    }

    // MARK: - Oyunçu səhifəsi

    static func playerDetail(from dto: PlayerStatsDTO,
                             reference: PlayerReference,
                             season: Int) -> PlayerDetailContent {
        // Mövsümdə oynamadığı turnirlər (0 oyun) siyahını doldurmasın.
        let stats = dto.statistics.filter { ($0.games?.appearences?.value ?? 0) > 0 }
        // Əsas klub: ən çox oyun keçirdiyi komanda (mövsüm ortası transfer ola bilər).
        let main = stats.max { ($0.games?.appearences?.value ?? 0) < ($1.games?.appearences?.value ?? 0) }
            ?? dto.statistics.first

        let position = playerPosition(main?.games?.position)
        let isKeeper = position == .goalkeeper
        let clubName = main?.team?.name ?? reference.clubName ?? "–"

        let profile = PlayerProfile(
            name: dto.player.name ?? reference.name,
            number: main?.games?.number?.value ?? reference.number,
            position: position,
            age: dto.player.age,
            nationality: dto.player.nationality ?? "",
            flag: CountryFlag.emoji(forCountryName: dto.player.nationality) ?? "",
            height: dto.player.height,
            photoURL: dto.player.photo,
            club: ClubReference(name: clubName, id: main?.team?.id)
        )

        let total = StatTotals(stats)
        let rating = averageRating(stats)
        var sections = statSections(total, isKeeper: isKeeper, rating: rating)
        // Hər turnir ayrıca: "Premier League · 12 apps, 5 goals".
        let competitions = stats.map { stat -> PlayerStatRow in
            let apps = stat.games?.appearences?.value ?? 0
            var parts = ["\(apps) apps"]
            if !isKeeper { parts.append("\(stat.goals?.total?.value ?? 0) goals") }
            return PlayerStatRow(label: stat.league?.name ?? "–", value: parts.joined(separator: ", "))
        }
        if !competitions.isEmpty {
            sections.append(PlayerStatSection(title: "Competitions", rows: competitions))
        }

        return PlayerDetailContent(profile: profile,
                                   season: seasonText(season),
                                   summary: summary(total, isKeeper: isKeeper, rating: rating),
                                   statistics: sections)
    }

    /// Overview-dakı 4 əsas göstərici.
    private static func summary(_ total: StatTotals, isKeeper: Bool, rating: String) -> [PlayerStatRow] {
        let apps = text(total.sum { $0.games?.appearences })
        if isKeeper {
            return [
                PlayerStatRow(label: "Matches", value: apps),
                PlayerStatRow(label: "Saves", value: text(total.sum { $0.goals?.saves })),
                PlayerStatRow(label: "Conceded", value: text(total.sum { $0.goals?.conceded })),
                PlayerStatRow(label: "Rating", value: rating)
            ]
        }
        return [
            PlayerStatRow(label: "Matches", value: apps),
            PlayerStatRow(label: "Goals", value: text(total.sum { $0.goals?.total })),
            PlayerStatRow(label: "Assists", value: text(total.sum { $0.goals?.assists })),
            PlayerStatRow(label: "Rating", value: rating)
        ]
    }

    /// Statistics tab-ı: bütün turnirlərin cəmi.
    private static func statSections(_ total: StatTotals, isKeeper: Bool, rating: String) -> [PlayerStatSection] {
        var sections = [
            PlayerStatSection(title: "General", rows: [
                PlayerStatRow(label: "Appearances", value: text(total.sum { $0.games?.appearences })),
                PlayerStatRow(label: "Starts", value: text(total.sum { $0.games?.lineups })),
                PlayerStatRow(label: "Minutes played", value: text(total.sum { $0.games?.minutes })),
                PlayerStatRow(label: "Average rating", value: rating)
            ])
        ]

        if isKeeper {
            sections.append(PlayerStatSection(title: "Goalkeeping", rows: [
                PlayerStatRow(label: "Saves", value: text(total.sum { $0.goals?.saves })),
                PlayerStatRow(label: "Goals conceded", value: text(total.sum { $0.goals?.conceded })),
                PlayerStatRow(label: "Penalties saved", value: text(total.sum { $0.penalty?.saved }))
            ]))
        } else {
            sections.append(PlayerStatSection(title: "Attacking", rows: [
                PlayerStatRow(label: "Goals", value: text(total.sum { $0.goals?.total })),
                PlayerStatRow(label: "Assists", value: text(total.sum { $0.goals?.assists })),
                PlayerStatRow(label: "Shots", value: text(total.sum { $0.shots?.total })),
                PlayerStatRow(label: "Shots on target", value: text(total.sum { $0.shots?.on })),
                PlayerStatRow(label: "Penalties scored", value: text(total.sum { $0.penalty?.scored }))
            ]))
        }

        sections.append(PlayerStatSection(title: "Passing", rows: [
            PlayerStatRow(label: "Passes", value: text(total.sum { $0.passes?.total })),
            PlayerStatRow(label: "Key passes", value: text(total.sum { $0.passes?.key }))
        ]))

        let duels = total.sum { $0.duels?.total }
        let duelsWon = total.sum { $0.duels?.won }
        sections.append(PlayerStatSection(title: "Defending", rows: [
            PlayerStatRow(label: "Tackles", value: text(total.sum { $0.tackles?.total })),
            PlayerStatRow(label: "Interceptions", value: text(total.sum { $0.tackles?.interceptions })),
            PlayerStatRow(label: "Duels won", value: percentText(duelsWon, of: duels))
        ]))

        sections.append(PlayerStatSection(title: "Discipline", rows: [
            PlayerStatRow(label: "Yellow cards", value: text(total.sum { $0.cards?.yellow })),
            PlayerStatRow(label: "Red cards", value: text(total.sum { $0.cards?.red })),
            PlayerStatRow(label: "Fouls committed", value: text(total.sum { $0.fouls?.committed }))
        ]))
        return sections
    }

    // MARK: - Köməkçilər

    /// "Attacker" → forward; boşdursa nil.
    static func playerPosition(_ text: String?) -> PlayerPosition? {
        guard let text, !text.isEmpty else { return nil }
        return mapPosition(text)
    }

    /// 2024 → "2024/25".
    static func seasonText(_ season: Int) -> String {
        let next = (season + 1) % 100
        return "\(season)/\(next < 10 ? "0" : "")\(next)"
    }

    /// Bütün turnirlərdəki oyun sayına görə orta reytinq.
    private static func averageRating(_ stats: [PlayerStatsDTO.Statistic]) -> String {
        var weighted = 0.0
        var games = 0
        for stat in stats {
            guard let text = stat.games?.rating, let rating = Double(text) else { continue }
            let apps = max(stat.games?.appearences?.value ?? 1, 1)
            weighted += rating * Double(apps)
            games += apps
        }
        guard games > 0 else { return "–" }
        return String(format: "%.2f", weighted / Double(games))
    }

    private static func text(_ value: Int?) -> String {
        value.map { "\($0)" } ?? "–"
    }

    private static func percentText(_ part: Int?, of whole: Int?) -> String {
        guard let part, let whole, whole > 0 else { return "–" }
        return "\(Int((Double(part) / Double(whole) * 100).rounded()))%"
    }
}

/// Turnirlər üzrə cəm. Heç bir turnirdə dəyər yoxdursa nil ("–" göstərilir), 0 deyil.
private struct StatTotals {

    let stats: [PlayerStatsDTO.Statistic]

    init(_ stats: [PlayerStatsDTO.Statistic]) {
        self.stats = stats
    }

    func sum(_ value: (PlayerStatsDTO.Statistic) -> FlexibleInt?) -> Int? {
        let values = stats.compactMap { value($0)?.value }
        return values.isEmpty ? nil : values.reduce(0, +)
    }
}
