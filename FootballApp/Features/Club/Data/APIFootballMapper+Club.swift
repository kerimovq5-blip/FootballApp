//
//  APIFootballMapper+Club.swift
//  FootballApp
//
//  Klub səhifəsi: profil, oyunlar, cədvəllər, heyət.
//

import Foundation

extension APIFootballMapper {

    // MARK: - Klub

    static func clubDetail(reference: ClubReference,
                           team: TeamInfoDTO,
                           fixtures: [FixtureDTO],
                           standingDTOs: [StandingsDTO],
                           squad: [SquadDTO]) -> ClubDetailContent {
        let name = team.team.name
        let key = ClubKey.make(name)

        // Cədvəllər: domestik liqa birinci, Avropa turnirləri sonra (API "World" yazır, biz "Europe").
        let tables = standingDTOs.compactMap { dto -> ClubTable? in
            let rows = standings(from: [dto], filter: .all)
            guard !rows.isEmpty else { return nil }
            let info = dto.league
            let isInternational = info.country == nil || info.country == "World"
            let league = League(id: info.id,
                                name: info.name,
                                country: isInternational ? "Europe" : (info.country ?? ""),
                                flag: flagEmoji(fromURL: info.flag),
                                matches: [])
            return ClubTable(league: league, standings: rows)
        }
        let ordered = tables.filter { $0.league.country != "Europe" }
            + tables.filter { $0.league.country == "Europe" }
        let domestic = ordered.first { $0.league.country != "Europe" }

        // Oyunlar: bitənlər nəticələrə (ən yenisi birinci), qalanlar gələcək oyunlara.
        let finished = fixtures.filter(isFinished).sorted { $0.fixture.date > $1.fixture.date }
        let others = fixtures.filter { !isFinished($0) }.sorted { $0.fixture.date < $1.fixture.date }
        let results = finished.prefix(10).map(clubMatch)
        let upcoming = others.prefix(10).map(clubMatch)

        let form = results.prefix(5).compactMap { $0.result(for: key) }.reversed()

        let players = (squad.first?.players ?? []).map { player in
            SquadPlayer(number: player.number ?? 0,
                        name: player.name,
                        position: mapPosition(player.position),
                        age: player.age ?? 0,
                        nationality: "",
                        flag: "",
                        id: player.id)
        }

        let profile = ClubProfile(name: name,
                                  country: reference.country ?? team.team.country,
                                  flag: reference.flag ?? domestic?.league.flag,
                                  founded: team.team.founded,
                                  stadium: team.venue?.name,
                                  competitions: ordered.map { $0.league.name })

        return ClubDetailContent(profile: profile,
                                 form: Array(form),
                                 upcoming: Array(upcoming),
                                 results: Array(results),
                                 tables: ordered,
                                 squad: players)
    }

    private static func isFinished(_ dto: FixtureDTO) -> Bool {
        if case .finished = mapStatus(dto) { return true }
        return false
    }

    private static func clubMatch(_ dto: FixtureDTO) -> ClubMatch {
        let status = mapStatus(dto)
        return ClubMatch(matchID: dto.fixture.id,
                         competition: dto.league.name,
                         dateText: shortDayText(dto.fixture.date),
                         home: dto.teams.home.name,
                         away: dto.teams.away.name,
                         homeScore: dto.goals.home,
                         awayScore: dto.goals.away,
                         statusText: status.displayText,
                         isLive: status.isLive)
    }
}
