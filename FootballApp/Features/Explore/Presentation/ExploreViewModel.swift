//
//  ExploreViewModel.swift
//  FootballApp
//
//  Created by Servan on 09.10.26.
//

import Foundation

final class ExploreViewModel {

    /// Data və ya seçilmiş tab dəyişəndə çağırılır; ekran reload edir.
    var onChange: (() -> Void)?
    var onFailed: ((UserFacingError) -> Void)?
    /// Reytinq şəbəkədən yüklənməyə başlayanda (tab və ya liqa dəyişəndə).
    var onLoading: (() -> Void)?

    private(set) var selectedTab: ExploreTab = .leagues
    private(set) var selectedLeague: League?
    let leagues: [League]
    private(set) var rankings: [RankingEntry] = []

    private let service: ExploreProviding
    /// Eyni tab + liqa ikinci dəfə açılanda sorğu göndərilmir.
    private var cache: [String: [RankingEntry]] = [:]
    /// Tez-tez dəyişəndə gec gələn köhnə cavab yeni seçimin üstünə yazılmasın.
    private var requestID = 0

    init(service: ExploreProviding) {
        self.service = service
        self.leagues = service.leagues
        self.selectedLeague = leagues.first
    }

    // MARK: - Output

    var numberOfRows: Int {
        selectedTab == .leagues ? leagues.count : rankings.count
    }

    // MARK: - Input

    /// Liqalar yerli siyahıdır, sorğu lazım deyil.
    func load() {
        onChange?()
    }

    func select(_ tab: ExploreTab) {
        guard tab != selectedTab else { return }
        selectedTab = tab
        loadRankings()
    }

    func selectLeague(at index: Int) {
        guard leagues.indices.contains(index), leagues[index].id != selectedLeague?.id else { return }
        selectedLeague = leagues[index]
        loadRankings()
    }

    /// Xəta ekranındakı "Try again".
    func retry() {
        loadRankings()
    }

    // MARK: - Private

    private func loadRankings() {
        guard let kind = selectedTab.topPlayersKind, let league = selectedLeague else {
            rankings = []
            onChange?()
            return
        }

        let key = "\(kind)-\(league.id)"
        if let cached = cache[key] {
            rankings = cached
            onChange?()
            return
        }

        rankings = []
        requestID += 1
        let currentRequest = requestID
        onLoading?()

        Task { [weak self, service] in
            do {
                let entries = try await service.topPlayers(kind, in: league)
                guard let self, currentRequest == self.requestID else { return }
                self.cache[key] = entries
                self.rankings = entries
                self.onChange?()
            } catch {
                guard let self, currentRequest == self.requestID else { return }
                self.onFailed?(UserFacingError(error))
            }
        }
    }
}
