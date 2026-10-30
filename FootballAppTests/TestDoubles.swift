//
//  TestDoubles.swift
//  FootballAppTests
//
//  ViewModel testləri üçün saxta servislər. Real API-yə getmirlər,
//  cavabı testin özü verir və hansı sorğuların göndərildiyini yadda saxlayırlar.
//

import Foundation
@testable import FootballApp

struct TestError: LocalizedError {
    var message = "Something went wrong"
    var errorDescription: String? { message }
}

// MARK: - Ekran modelləri

extension TestData {

    static func match(id: Int, home: String = "Arsenal", away: String = "Chelsea",
                      status: MatchStatus = .finished) -> Match {
        Match(id: id, home: home, away: away, homeScore: 1, awayScore: 0, status: status)
    }

    static func league(id: Int, name: String = "Premier League", country: String = "England",
                       matches: [Match] = []) -> League {
        League(id: id, name: name, country: country, flag: "🏳️", matches: matches)
    }

    static func standing(position: Int, team: String) -> Standing {
        Standing(position: position, teamName: team,
                 played: 10, wins: 5, draws: 3, losses: 2, goalsFor: 15, goalsAgainst: 10,
                 zone: .none)
    }
}

// MARK: - Home

/// Cavabı dərhal vermir: test `respond(...)` ilə nə vaxt və hansı sırada cavab gələcəyini idarə edir.
@MainActor
final class FakeHomeService: HomeProviding {

    private(set) var requestedOffsets: [Int] = []
    private var pending: [(Result<HomeContent, Error>) -> Void] = []

    func fetchHome(dayOffset: Int, completion: @escaping (Result<HomeContent, Error>) -> Void) {
        requestedOffsets.append(dayOffset)
        pending.append(completion)
    }

    /// `index`-ci sorğuya cavab verir (0 = ilk sorğu).
    func respond(_ index: Int, leagues: [League]) {
        pending[index](.success(HomeContent(leagues: leagues)))
    }

    func fail(_ index: Int, message: String) {
        pending[index](.failure(TestError(message: message)))
    }
}

// MARK: - Standing

@MainActor
final class FakeStandingService: StandingProviding {

    let leagues: [League]
    var result: Result<[Standing], Error> = .success([])
    /// true olanda cavablar saxlanılır və `respond` ilə istənilən sırada verilir.
    var holdsResponses = false
    private(set) var requests: [(leagueID: Int, filter: StandingFilter)] = []
    private var pending: [(Result<[Standing], Error>) -> Void] = []
    
    init(leagues: [League]) {
        self.leagues = leagues
    }

    func fetchStandings(for league: League,
                        filter: StandingFilter,
                        completion: @escaping (Result<[Standing], Error>) -> Void) {
        requests.append((leagueID: league.id, filter: filter))
        if holdsResponses {
            pending.append(completion)
            return
        }
        completion(result)
    }

    func respond(_ index: Int, with result: Result<[Standing], Error>) {
        pending[index](result)
    }
}

// MARK: - Search

/// API kimi davranır: komanda və oyunçuları adında sorğu olanlara görə süzür.
@MainActor
final class FakeSearchService: SearchProviding {

    var result: Result<SearchContent, Error>
    var remote: RemoteSearchResults
    var remoteError: Error?
    private(set) var remoteQueries: [String] = []

    init(
        content: SearchContent,
        remote: RemoteSearchResults = RemoteSearchResults()
    ) {
        result = .success(content)
        self.remote = remote
    }

    func fetchSearchContent(completion: @escaping (Result<SearchContent, Error>) -> Void) {
        completion(result)
    }

    func searchRemote(_ query: String) async throws -> RemoteSearchResults {
        remoteQueries.append(query)
        if let remoteError { throw remoteError }
        func matches(_ name: String) -> Bool {
            name.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
        return RemoteSearchResults(clubs: remote.clubs.filter { matches($0.name) },
                                   players: remote.players.filter { matches($0.reference.name) })
    }
}

/// UserDefaults əvəzinə yaddaşda saxlayır, ona görə testlər bir-birinə və tətbiqə təsir etmir.
@MainActor
final class InMemoryRecentSearchStore: RecentSearchStoring {

    private(set) var items: [String]

    init(items: [String] = []) {
        self.items = items
    }

    func add(_ query: String) {
        items.removeAll { $0.caseInsensitiveCompare(query) == .orderedSame }
        items.insert(query, at: 0)
    }

    func clear() {
        items = []
    }
}

// MARK: - Club

@MainActor
final class FakeClubService: ClubProviding {

    var result: Result<ClubDetailContent, Error>
    private(set) var requestedNames: [String] = []

    init(result: Result<ClubDetailContent, Error>) {
        self.result = result
    }

    func fetchClub(_ club: ClubReference) async -> Result<ClubDetailContent, Error> {
        requestedNames.append(club.name)
        return result
    }

    static func content(name: String) -> ClubDetailContent {
        ClubDetailContent(
            profile: ClubProfile(name: name, country: "England", flag: nil, founded: 1886,
                                 stadium: "Emirates Stadium", competitions: []),
            form: [],
            upcoming: [],
            results: [],
            tables: [],
            squad: []
        )
    }
}

// MARK: - Explore

@MainActor
final class FakeExploreService: ExploreProviding {

    let leagues: [League]
    var result: Result<[RankingEntry], Error> = .success([])
    private(set) var requests: [(kind: TopPlayersKind, leagueID: Int)] = []

    init(leagues: [League]) {
        self.leagues = leagues
    }

    func topPlayers(_ kind: TopPlayersKind, in league: League) async throws -> [RankingEntry] {
        requests.append((kind: kind, leagueID: league.id))
        return try result.get()
    }

    static func entry(rank: Int, name: String) -> RankingEntry {
        RankingEntry(rank: rank, name: name, subtitle: "Arsenal", imageURL: nil, value: "10",
                     player: PlayerReference(name: name, id: rank))
    }
}

// MARK: - Bildirişlər

@MainActor
final class FakeReminderScheduler: MatchReminderScheduling {

    var isAuthorized = true
    private(set) var authorizationRequests = 0
    private(set) var scheduled: [(matchID: Int, date: Date)] = []
    private(set) var cancelledIDs: [Int] = []
    private(set) var cancelAllCount = 0

    func requestAuthorization() async -> Bool {
        authorizationRequests += 1
        return isAuthorized
    }

    func schedule(_ reminder: MatchReminder, at date: Date) async throws {
        scheduled.append((matchID: reminder.matchID, date: date))
    }

    func cancel(matchID: Int) {
        cancelledIDs.append(matchID)
    }

    func cancelAll() {
        cancelAllCount += 1
    }
}

@MainActor
final class InMemorySubscriptionStore: MatchSubscriptionStoring {

    private(set) var subscribedMatchIDs: Set<Int> = []

    func isSubscribed(_ matchID: Int) -> Bool {
        subscribedMatchIDs.contains(matchID)
    }

    @discardableResult
    func toggle(_ matchID: Int) -> Bool {
        if subscribedMatchIDs.remove(matchID) != nil { return false }
        subscribedMatchIDs.insert(matchID)
        return true
    }

    func clear() {
        subscribedMatchIDs = []
    }
}

@MainActor
final class InMemoryReminderStore: MatchReminderStoring {

    private(set) var reminders: [MatchReminder] = []

    func save(_ reminder: MatchReminder) {
        reminders.removeAll { $0.matchID == reminder.matchID }
        reminders.append(reminder)
    }

    func remove(matchID: Int) {
        reminders.removeAll { $0.matchID == matchID }
    }

    func clear() {
        reminders = []
    }
}

@MainActor
final class InMemorySettingsStore: SettingsStoring {
    var notificationsEnabled = true
}
