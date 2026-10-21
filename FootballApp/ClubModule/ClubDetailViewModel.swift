//
//  ClubDetailViewModel.swift
//  FootballApp
//
//  Created by Servan on 11.10.26.
//

//
//  ClubDetailViewModel.swift
//  FootballApp
//

import Foundation

final class ClubDetailViewModel {
    
    var onLoaded: ((ClubDetailContent) -> Void)?
    var onFailed: ((UserFacingError) -> Void)?
    
    let club: ClubReference
    private let service: ClubProviding
    
    init(club: ClubReference, service: ClubProviding) {
        self.club = club
        self.service = service
    }
    
    func load() {
        Task { [weak self] in
            guard let self else { return }
            let result = await service.fetchClub(club)
            switch result {
            case .success(let content):
                onLoaded?(content)
            case .failure(let error):
                onFailed?(UserFacingError(error))
            }
        }
    }
}
