//
//  ClubProviding.swift
//  FootballApp
//
//  Created by Servan on 11.10.26.
//

import Foundation

protocol ClubProviding {
    func fetchClub(_ club: ClubReference) async -> Result<ClubDetailContent, Error>
}
