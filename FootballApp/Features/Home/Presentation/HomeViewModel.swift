//
//  HomeViewModel.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//
import Foundation
import UIKit

enum HomeSection {
    case day
    case filter
    case league(index: Int)
    case empty
    /// Seçilmiş günün datası yüklənir.
    case loading
    /// Data yüklənmədi; "Try again" ilə yenidən cəhd edilir.
    case error
}

final class HomeViewModel {

    /// Data, gün və ya filter dəyişəndə çağırılır; ekran reload edir.
    var onChange: (() -> Void)?
    var onFailed: ((UserFacingError) -> Void)?

    private let service: HomeProviding

    private(set) var selectedDay: HomeDay = .today
    private(set) var selectedFilter: MatchFilter = .all
    private(set) var filteredLeagues: [League] = []
    private(set) var sections: [HomeSection] = [.day, .filter, .loading]
    /// Son yükləmənin xətası; uğurlu cavab və ya yeni gün seçimi onu silir.
    private(set) var loadError: UserFacingError?

    private var leagues: [League] = []
    /// Seçilmiş günün datası gəlməyib də "oyun yoxdur" yazısı çıxmasın.
    private var hasLoaded = false
    /// Tez-tez gün dəyişəndə gec gələn köhnə cavab yeni günün üstünə yazmasın.
    private var requestID = 0

    init(service: HomeProviding) {
        self.service = service
    }

    // MARK: - Output

    /// Boş siyahıda göstərilən mesaj.
    var emptyMessage: String {
        selectedFilter == .live ? "No live matches right now." : "No matches on this day."
    }

    // MARK: - Input

    func load() {
        requestID += 1
        let currentRequest = requestID

        service.fetchHome(dayOffset: selectedDay.offset) { [weak self] result in
            guard let self, currentRequest == self.requestID else { return }
            switch result {
            case .success(let content):
                self.leagues = content.leagues
                self.hasLoaded = true
                self.loadError = nil
                self.refresh()
            case .failure(let error):
                let failure = UserFacingError(error)
                self.loadError = failure
                self.refresh()
                self.onFailed?(failure)
            }
        }
    }

    func selectDay(_ day: HomeDay) {
        guard day != selectedDay else { return }
        selectedDay = day
        // Köhnə günün oyunları yeni gün yüklənənə qədər görünməsin.
        leagues = []
        hasLoaded = false
        loadError = nil
        refresh()
        load()
    }

    /// Xəta ekranındakı "Try again".
    func retry() {
        loadError = nil
        refresh()
        load()
    }

    func selectFilter(_ filter: MatchFilter) {
        guard filter != selectedFilter else { return }
        selectedFilter = filter
        refresh()
    }

    // MARK: - Lookup

    func league(inSection section: Int) -> League? {
        guard case .league(let index) = sections[section] else { return nil }
        return filteredLeagues[index]
    }

    func match(at indexPath: IndexPath) -> Match? {
        league(inSection: indexPath.section)?.matches[indexPath.item]
    }

    // MARK: - Private

    /// Filter nəticəsi hər dəyişiklikdə bir dəfə hesablanır.
    private func refresh() {
        switch selectedFilter {
        case .all:
            filteredLeagues = leagues
        case .live:
            filteredLeagues = leagues.compactMap { league in
                let live = league.matches.filter { $0.status.isLive }
                guard !live.isEmpty else { return nil }
                return League(id: league.id, name: league.name, country: league.country,
                              flag: league.flag, matches: live)
            }
        }

        var result: [HomeSection] = [.day, .filter]
        result += filteredLeagues.indices.map { HomeSection.league(index: $0) }
        if filteredLeagues.isEmpty {
            if loadError != nil {
                result.append(.error)
            } else if hasLoaded {
                result.append(.empty)
            } else {
                result.append(.loading)
            }
        }
        sections = result
        onChange?()
    }
}
