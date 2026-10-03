//
//  HomeService.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//

import Foundation

struct HomeContent {
    let banners: [Banner]
    let leagues: [League]
}

protocol HomeProviding {
    func fetchHome(completion: @escaping (Result<HomeContent, Error>) -> Void)
}

/// Real API gələnə qədər müvəqqəti implementasiya.
struct MockHomeService: HomeProviding {
    func fetchHome(completion: @escaping (Result<HomeContent, Error>) -> Void) {
        completion(.success(HomeContent(banners: HomeMockData.banners, leagues: MockData.leagues)))
    }
}
