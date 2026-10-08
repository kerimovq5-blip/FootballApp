//
//  NetworkFactory.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 08.10.26.
//

import Foundation

struct NetworkFactory {
    static func make() -> (
        sessionStore: UserDefaultsSessionStore,
        NetworkManager: NetworkManager
    ) {
        let sessionStore = UserDefaultsSessionStore(
            keys : SessionKeys (
                accessTokenKey: "accessToken",
                refreshTokenKey: "refreshToken",
                
            )
                
        )
        let networkManager = NetworkManager(
            session: URLSession.shared,
            mainPath: "",
            header: [
                "Accept": "application/json",
                      "Content-Type": "application/json"] ,
        
        )
        return (sessionStore, networkManager)
        
    }
}
