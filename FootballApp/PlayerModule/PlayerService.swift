//
//  PlayerProviding.swift
//  FootballApp
//
//  Created by Servan on 12.10.26.
//


//
//  PlayerService.swift
//  FootballApp
//

import Foundation

protocol PlayerProviding {
    func fetchPlayer(_ player: PlayerReference) async -> Result<PlayerDetailContent, Error>
}

/// Real API gələnə qədər test datası. Bütün rəqəmlər uydurmadır, oyunçu adından hesablanır.
struct MockPlayerService: PlayerProviding {

    private let clubService: ClubProviding

    init(clubService: ClubProviding = MockClubService()) {
        self.clubService = clubService
    }

    func fetchPlayer(_ player: PlayerReference) async -> Result<PlayerDetailContent, Error> {
        let result = await clubService.fetchClub(ClubReference(name: player.clubName ?? ""))
        return result.map { MockPlayerService.makeContent(player: player, club: $0) }
    }

    // MARK: - Məzmun

    private static func makeContent(player reference: PlayerReference,
                                    club: ClubDetailContent) -> PlayerDetailContent {
        let clubKey = ClubKey.make(club.profile.name)
        let nameKey = ClubKey.make(reference.name)
        let player = club.squad.first { ClubKey.make($0.name) == nameKey }
            ?? fallbackPlayer(for: reference, club: club.profile, clubKey: clubKey)

        var rng = SeededGenerator(seed: "\(clubKey)#\(nameKey)#detail")
        let position = player.position
        let index = PlayerPosition.allCases.firstIndex(of: position) ?? 0
        let isKeeper = position == .goalkeeper

        // Profil
        let heights = [186, 181, 177, 178]
        let profile = PlayerProfile(
            name: player.name,
            number: player.number,
            position: position,
            age: player.age,
            nationality: player.nationality,
            flag: player.flag,
            heightCm: heights[index] + rng.next(12),
            preferredFoot: rng.next(10) < 7 ? "Right" : "Left",
            club: ClubReference(name: club.profile.name,
                                country: club.profile.country,
                                flag: club.profile.flag)
        )

        // Oyunlar: klubun nəticələri, hər oyunda oyunçunun göstəriciləri
        let minuteOptions = isKeeper ? [90, 90, 90, 90, 90, 90, 0] : [90, 90, 90, 90, 78, 64, 45, 22, 0]
        let matches: [PlayerMatch] = club.results.map { match in
            let minutes = minuteOptions[rng.next(minuteOptions.count)]
            let played = minutes > 0

            var goals = 0
            if played {
                switch position {
                case .goalkeeper: break
                case .defender: goals = rng.next(15) == 0 ? 1 : 0
                case .midfielder: goals = rng.next(7) == 0 ? 1 : 0
                case .forward: goals = [0, 0, 0, 1, 1, 2][rng.next(6)]
                }
            }
            var assists = 0
            if played && !isKeeper {
                assists = rng.next(position == .defender ? 14 : 6) == 0 ? 1 : 0
            }
            let yellow = played && rng.next(8) == 0 ? 1 : 0
            let red = played && rng.next(60) == 0 ? 1 : 0

            var rating: Double?
            if played {
                let raw = 6.0 + Double(rng.next(21)) / 10 + Double(goals) * 0.7
                    + Double(assists) * 0.4 - Double(red) * 1.5
                rating = (min(10, max(4.5, raw)) * 10).rounded() / 10
            }

            return PlayerMatch(matchID: match.matchID, competition: match.competition,
                               dateText: match.dateText, home: match.home, away: match.away,
                               homeScore: match.homeScore, awayScore: match.awayScore,
                               minutes: minutes, goals: goals, assists: assists,
                               yellowCards: yellow, redCards: red, rating: rating)
        }

        // Mövsüm statistikası: siyahıdakı oyunlar + əvvəlki oyunlar (test datası)
        let listed = matches.filter { $0.didPlay }
        let earlierApps = 3 + rng.next(3)
        let earlierMinutes = earlierApps * (60 + rng.next(31))
        let totalMinutes = listed.map { $0.minutes }.reduce(0, +) + earlierMinutes
        let games90 = Double(totalMinutes) / 90
        let earlier90 = Double(earlierMinutes) / 90

        /// Mövqeyə görə (qapıçı, müdafiəçi, yarımmüdafiəçi, hücumçu) 90 dəqiqəlik norma × bütün dəqiqələr.
        func total(_ rates: [Double]) -> Int {
            Int((games90 * rates[index] * (0.75 + Double(rng.next(50)) / 100)).rounded())
        }
        func earlier(_ rates: [Double]) -> Int {
            Int((earlier90 * rates[index] * (0.75 + Double(rng.next(50)) / 100)).rounded())
        }

        let apps = listed.count + earlierApps
        let starts = listed.filter { $0.minutes >= 60 }.count + max(0, earlierApps - rng.next(2))
        let goals = listed.map { $0.goals }.reduce(0, +) + earlier([0, 0.05, 0.15, 0.5])
        let assists = listed.map { $0.assists }.reduce(0, +) + earlier([0, 0.08, 0.2, 0.25])
        let yellow = listed.map { $0.yellowCards }.reduce(0, +) + rng.next(2)
        let red = listed.map { $0.redCards }.reduce(0, +)

        let ratings = matches.compactMap { $0.rating }
        let ratingText = ratings.isEmpty ? "–" : PlayerRating.text(ratings.reduce(0, +) / Double(ratings.count))

        let shots = total([0, 0.5, 1.2, 2.6])
        let passAccuracy = [72, 86, 84, 76][index] + rng.next(8)

        var sections: [PlayerStatSection] = [
            PlayerStatSection(title: "General", rows: [
                PlayerStatRow(label: "Appearances", value: "\(apps)"),
                PlayerStatRow(label: "Starts", value: "\(starts)"),
                PlayerStatRow(label: "Minutes played", value: "\(totalMinutes)"),
                PlayerStatRow(label: "Average rating", value: ratingText)
            ])
        ]

        let summary: [PlayerStatRow]
        if isKeeper {
            let pairs = zip(club.results, matches).filter { $1.didPlay }
            let cleanSheets = pairs.filter { conceded($0.0, clubKey: clubKey) == 0 }.count + rng.next(3)
            let goalsConceded = pairs.map { conceded($0.0, clubKey: clubKey) }.reduce(0, +)
                + earlierApps + rng.next(4)
            let saves = total([2.8, 0, 0, 0])

            sections.append(PlayerStatSection(title: "Goalkeeping", rows: [
                PlayerStatRow(label: "Saves", value: "\(saves)"),
                PlayerStatRow(label: "Save percentage", value: "\(66 + rng.next(14))%"),
                PlayerStatRow(label: "Clean sheets", value: "\(cleanSheets)"),
                PlayerStatRow(label: "Goals conceded", value: "\(goalsConceded)"),
                PlayerStatRow(label: "Penalties saved", value: "\(rng.next(10) == 0 ? 1 : 0)")
            ]))
            sections.append(PlayerStatSection(title: "Passing", rows: [
                PlayerStatRow(label: "Passes completed", value: "\(total([18, 0, 0, 0]))"),
                PlayerStatRow(label: "Pass accuracy", value: "\(passAccuracy)%")
            ]))
            summary = [
                PlayerStatRow(label: "Matches", value: "\(apps)"),
                PlayerStatRow(label: "Clean sheets", value: "\(cleanSheets)"),
                PlayerStatRow(label: "Saves", value: "\(saves)"),
                PlayerStatRow(label: "Rating", value: ratingText)
            ]
        } else {
            let onTarget = min(shots, Int((Double(shots) * 0.4).rounded()))
            sections.append(PlayerStatSection(title: "Attacking", rows: [
                PlayerStatRow(label: "Goals", value: "\(goals)"),
                PlayerStatRow(label: "Assists", value: "\(assists)"),
                PlayerStatRow(label: "Shots", value: "\(shots)"),
                PlayerStatRow(label: "Shots on target", value: "\(onTarget)"),
                PlayerStatRow(label: "Key passes", value: "\(total([0.1, 0.4, 1.3, 1.0]))")
            ]))
            sections.append(PlayerStatSection(title: "Passing", rows: [
                PlayerStatRow(label: "Passes completed", value: "\(total([18, 45, 42, 22]))"),
                PlayerStatRow(label: "Pass accuracy", value: "\(passAccuracy)%")
            ]))
            sections.append(PlayerStatSection(title: "Defending", rows: [
                PlayerStatRow(label: "Tackles", value: "\(total([0, 2.0, 2.1, 0.8]))"),
                PlayerStatRow(label: "Interceptions", value: "\(total([0, 1.4, 1.2, 0.4]))"),
                PlayerStatRow(label: "Clearances", value: "\(total([2, 3.2, 0.9, 0.3]))"),
                PlayerStatRow(label: "Duels won", value: "\([50, 58, 52, 47][index] + rng.next(10))%")
            ]))
            summary = [
                PlayerStatRow(label: "Matches", value: "\(apps)"),
                PlayerStatRow(label: "Goals", value: "\(goals)"),
                PlayerStatRow(label: "Assists", value: "\(assists)"),
                PlayerStatRow(label: "Rating", value: ratingText)
            ]
        }

        sections.append(PlayerStatSection(title: "Discipline", rows: [
            PlayerStatRow(label: "Yellow cards", value: "\(yellow)"),
            PlayerStatRow(label: "Red cards", value: "\(red)"),
            PlayerStatRow(label: "Fouls committed", value: "\(total([0.2, 1.0, 1.2, 1.1]))")
        ]))

        return PlayerDetailContent(profile: profile, season: "2026/27", summary: summary,
                                   matches: matches, statistics: sections)
    }

    /// Klubun həmin oyunda buraxdığı qol sayı.
    private static func conceded(_ match: ClubMatch, clubKey: String) -> Int {
        let isHome = ClubKey.make(match.home) == clubKey
        return (isHome ? match.awayScore : match.homeScore) ?? 0
    }

    /// Heyətdə tapılmayan oyunçu (məs. Line Up-dakı ad) üçün ehtiyat profil.
    private static func fallbackPlayer(for reference: PlayerReference,
                                       club: ClubProfile,
                                       clubKey: String) -> SquadPlayer {
        var traits = SeededGenerator(seed: "\(clubKey)#\(reference.name)")
        let number = reference.number ?? (1 + traits.next(30))
        return SquadPlayer(number: number,
                           name: reference.name,
                           position: MockSquad.position(forNumber: number) ?? .midfielder,
                           age: 19 + traits.next(16),
                           nationality: club.country ?? "–",
                           flag: club.flag ?? "🏳️")
    }
}
