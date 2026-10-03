//
//  HomeViewModel.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//
import UIKit
import Foundation

enum HomeSection {
    case banner
    case filter
    case league(index: Int)
}

final class HomeViewModel {

    /// Data və ya filter dəyişəndə çağırılır; ekran reload edir.
    var onChange: (() -> Void)?
    var onFailed: ((String) -> Void)?

    private let service: HomeProviding

    private(set) var banners: [Banner] = []
    private(set) var selectedFilter: MatchFilter = .all
    private(set) var filteredLeagues: [League] = []
    private(set) var sections: [HomeSection] = [.banner, .filter]

    private var leagues: [League] = []

    init(service: HomeProviding) {
        self.service = service
    }

    // MARK: - Input

    func load() {
        service.fetchHome { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let content):
                self.banners = content.banners
                self.leagues = content.leagues
                self.refresh()
            case .failure(let error):
                self.onFailed?(error.localizedDescription)
            }
        }
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

    /// Filter nəticəsi hər dəyişiklikdə bir dəfə hesablanır (əvvəl hər çağırışda yenidən hesablanırdı).
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
        sections = [.banner, .filter] + filteredLeagues.indices.map { HomeSection.league(index: $0) }
        onChange?()
    }
}
