//
//  MatchDetailViewModel.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//

import Foundation

final class MatchDetailViewModel {

    var onLoaded: ((MatchDetailData) -> Void)?
    var onFailed: ((String) -> Void)?

    private let matchID: Int
    private let service: MatchDetailProviding

    init(matchID: Int, service: MatchDetailProviding) {
        self.matchID = matchID
        self.service = service
    }

    func load() {
        service.fetchMatchDetail(id: matchID) { [weak self] result in
            switch result {
            case .success(let data):
                self?.onLoaded?(data)
            case .failure(let error):
                self?.onFailed?(error.localizedDescription)
            }
        }
    }
}
