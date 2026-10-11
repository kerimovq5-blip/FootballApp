//
//  MockSquad.swift
//  FootballApp
//
//  Created by Servan on 11.10.26.
//

//
//  MockSquad.swift
//  FootballApp
//

import Foundation

/// Real API gələnə qədər test heyəti. Adlar, yaşlar və vətəndaşlıqlar uydurmadır (real futbolçu deyil).
/// Eyni klub üçün həmişə eyni heyət çıxır.
enum MockSquad {

    static func make(clubKey: String, homeCountry: String?, homeFlag: String?) -> [SquadPlayer] {
        var rng = SeededGenerator(seed: clubKey)
        var usedNames = Set<String>()

        // Mövqe və forma nömrələri: 3 qapıçı, 8 müdafiəçi, 8 yarımmüdafiəçi, 6 hücumçu.
        let plan: [(PlayerPosition, [Int])] = [
            (.goalkeeper, [1, 13, 31]),
            (.defender, [2, 3, 4, 5, 12, 15, 23, 24]),
            (.midfielder, [6, 8, 10, 14, 16, 18, 20, 21]),
            (.forward, [7, 9, 11, 17, 19, 22])
        ]

        var players: [SquadPlayer] = []
        for (position, numbers) in plan {
            for number in numbers {
                var name = ""
                repeat {
                    name = "\(firstNames[rng.next(firstNames.count)]) \(lastNames[rng.next(lastNames.count)])"
                } while !usedNames.insert(name).inserted

                // Futbolçuların təxminən yarısı klubun öz ölkəsindəndir.
                let nationality: (country: String, flag: String)
                if let homeCountry, let homeFlag, rng.next(10) < 5 {
                    nationality = (homeCountry, homeFlag)
                } else {
                    nationality = nationalities[rng.next(nationalities.count)]
                }

                let isKeeper = position == .goalkeeper
                let age = (isKeeper ? 22 : 18) + rng.next(isKeeper ? 15 : 18)

                players.append(SquadPlayer(number: number, name: name, position: position, age: age,
                                           nationality: nationality.country, flag: nationality.flag))
            }
        }
        return players
    }

    // MARK: - Ad və vətəndaşlıq siyahıları

    private static let firstNames = [
        "Lucas", "Mateo", "Daniel", "Marco", "Jonas", "Emre", "Luka", "Andre", "Rafael", "Kai",
        "Omar", "Viktor", "Samuel", "Nico", "Hugo", "Leo", "Adam", "Felix", "Theo", "Ivan",
        "Pablo", "Yusuf", "Mehdi", "Tomas", "Oscar", "Rui", "Elias", "Mario", "Ben", "Alex"
    ]

    private static let lastNames = [
        "Silva", "Moreno", "Keller", "Rossi", "Novak", "Demir", "Costa", "Larsen", "Haddad", "Petrov",
        "Mendes", "Fischer", "Duarte", "Kovac", "Santos", "Berg", "Ferrari", "Yilmaz", "Dubois", "Navarro",
        "Okafor", "Lindqvist", "Torres", "Bianchi", "Hansen", "Ortega", "Mertens", "Aksoy", "Pereira", "Varga"
    ]

    private static let nationalities: [(country: String, flag: String)] = [
        ("Brazil", "🇧🇷"), ("Spain", "🇪🇸"), ("France", "🇫🇷"), ("Germany", "🇩🇪"),
        ("Portugal", "🇵🇹"), ("Argentina", "🇦🇷"), ("Netherlands", "🇳🇱"), ("Italy", "🇮🇹"),
        ("Turkey", "🇹🇷"), ("Croatia", "🇭🇷"), ("Morocco", "🇲🇦"), ("Nigeria", "🇳🇬")
    ]
}

/// Klub adından sabit başlanğıc alan təsadüfi say generatoru
/// (Swift-in hashValue-su hər açılışda dəyişir, ona görə FNV-1a istifadə olunur).
private struct SeededGenerator {
    private var state: UInt64

    init(seed: String) {
        var hash: UInt64 = 14695981039346656037
        for byte in seed.utf8 {
            hash = (hash ^ UInt64(byte)) &* 1099511628211
        }
        state = hash
    }

    mutating func next(_ upperBound: Int) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Int((state >> 33) % UInt64(upperBound))
    }
}
