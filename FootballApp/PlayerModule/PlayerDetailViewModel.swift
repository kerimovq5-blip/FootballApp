//
//  PlayerDetailViewModel.swift
//  FootballApp
//
//  Created by Servan on 12.10.26.
//


//
//  PlayerDetailViewModel.swift
//  FootballApp
//

import Foundation

final class PlayerDetailViewModel {

    var onLoaded: ((PlayerDetailContent) -> Void)?
    var onFailed: ((String) -> Void)?

    let player: PlayerReference
    private let service: PlayerProviding

    init(player: PlayerReference, service: PlayerProviding) {
        self.player = player
        self.service = service
    }

    func load() {
        service.fetchPlayer(player) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let content):
                self.onLoaded?(content)
            case .failure(let error):
                self.onFailed?(error.localizedDescription)
            }
        }
    }
}