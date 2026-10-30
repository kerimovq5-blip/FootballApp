//
//  StandingViewModel.swift
//  FootballApp
//
//  Created by Servan on 10.10.26.
//

//
//  StandingViewModel.swift
//  FootballApp
//

import Foundation

final class StandingViewModel {

    /// Cədvəl dəyişəndə çağırılır; ekran reload edir.
    var onChange: (() -> Void)?
    var onFailed: ((UserFacingError) -> Void)?
    var onLoadingStarted: (()-> Void)?

    private(set) var selectedLeagueIndex = 0
    private(set) var selectedFilter: StandingFilter = .all
    private(set) var standings: [Standing] = []
    private var requestID = 0
    private let service: StandingProviding

    init(service: StandingProviding){
        self.service = service
    }

    // MARK: - Output

    var leagues: [League] { service.leagues }
    var numberOfRows: Int { standings.count }

    // MARK: - Input

    func load() {
        fetch()
    }

    func selectLeague(at index: Int) {
        guard index != selectedLeagueIndex, leagues.indices.contains(index) else { return }
        selectedLeagueIndex = index
        fetch()
    }

    func select(_ filter: StandingFilter) {
        guard filter != selectedFilter else { return }
        selectedFilter = filter
        fetch()
    }

    // MARK: - Private

    private func fetch() {
        guard leagues.indices.contains(selectedLeagueIndex) else { return }
        let league = leagues[selectedLeagueIndex]

        requestID += 1
        let currentRequest = requestID
        onLoadingStarted?()

        service.fetchStandings(for: league, filter: selectedFilter) { [weak self] result in
            guard let self, currentRequest == self.requestID else { return }
            switch result {
            case .success(let standings):
                self.standings = standings
                self.onChange?()
            case .failure(let error):
                self.onFailed?(UserFacingError(error))
            }
        }
    }
}
