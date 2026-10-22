//
//  PlayerService.swift
//  FootballApp
//
//  Created by Servan on 12.10.26.
//

import Foundation

protocol PlayerProviding {
    func fetchPlayer(_ player: PlayerReference) async -> Result<PlayerDetailContent, Error>
}
