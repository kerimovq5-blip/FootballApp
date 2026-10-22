//
//  SearchService.swift
//  FootballApp
//

import Foundation

struct PlayerSearchResult {
    let reference: PlayerReference
    let position: PlayerPosition?
    /// Bayraq emojisi; tapılmasa boş.
    let flag: String
    var nationality: String?
    var photoURL: String?
}

/// Sorğusuz yüklənən hissə: yerli siyahıda filtrlənir.
struct SearchContent {
    /// Axtarışda liqa kimi tapılan liqalar.
    let leagues: [League]
    /// Oyunları olan liqalar (Home ilə eyni mənbə).
    let matchLeagues: [League]
}

/// Sorğuya görə API-dən gələn hissə.
struct RemoteSearchResults {
    var clubs: [ClubReference] = []
    var players: [PlayerSearchResult] = []
}

protocol SearchProviding {
    /// Liqalar və bu günün oyunları (bir dəfə yüklənir).
    func fetchSearchContent(completion: @escaping (Result<SearchContent, Error>) -> Void)
    /// Komanda və oyunçu axtarışı. Sorğu ən azı `SearchQuery.minimumLength` hərf olmalıdır.
    func searchRemote(_ query: String) async throws -> RemoteSearchResults
}

enum SearchQuery {
    /// API-Football komanda və oyunçu axtarışı ən azı 3 hərf istəyir.
    static let minimumLength = 3

    /// API yalnız hərf, rəqəm və boşluq qəbul edir: "Beşiktaş J.K." → "Besiktas J K".
    static func cleaned(_ text: String) -> String {
        let folded = text.folding(options: .diacriticInsensitive, locale: nil)
        return String(folded.map { $0.isLetter || $0.isNumber ? $0 : " " })
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Oyunçu soyadla axtarılır: "Mohamed Salah" → "Salah".
    static func playerSurname(_ text: String) -> String? {
        cleaned(text)
            .components(separatedBy: " ")
            .last { $0.count >= minimumLength }
    }
}
