//
//  MatchDetailService.swift
//  FootballApp
//
//  Created by Servan on 03.10.26.
//

import Foundation

protocol MatchDetailProviding {
    func fetchMatchDetail(id: Int, completion: @escaping (Result<MatchDetailData, Error>) -> Void)
}
