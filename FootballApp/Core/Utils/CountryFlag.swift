//
//  CountryFlag.swift
//  FootballApp
//
//  API oyunçunun ölkəsini adla verir ("Brazil", "England"). Ekranda bayraq emojisi göstərmək
//  üçün ad ISO koduna çevrilir. Tapılmasa nil qaytarılır və ekran bayraqsız göstərir.
//

import Foundation

enum CountryFlag {

    static func emoji(forCountryName name: String?) -> String? {
        guard let name, !name.isEmpty else { return nil }
        let key = normalize(name)
        if let special = footballNations[key] { return special }
        guard let code = codesByName[key] else { return nil }
        return emoji(forCode: code)
    }

    static func emoji(forCode code: String) -> String? {
        let upper = code.uppercased()
        guard upper.count == 2 else { return nil }
        var result = ""
        for scalar in upper.unicodeScalars {
            guard let flag = UnicodeScalar(127_397 + scalar.value) else { return nil }
            result.unicodeScalars.append(flag)
        }
        return result
    }

    // MARK: - Private

    /// Futbolda ayrıca komanda olan, amma ISO siyahısında ayrıca ölkə olmayanlar
    /// və API-nin fərqli yazdığı adlar.
    private static let footballNations: [String: String] = [
        "england": "🏴󠁧󠁢󠁥󠁮󠁧󠁿",
        "scotland": "🏴󠁧󠁢󠁳󠁣󠁴󠁿",
        "wales": "🏴󠁧󠁢󠁷󠁬󠁳󠁿",
        "northernireland": "🇬🇧",
        "usa": "🇺🇸",
        "korearepublic": "🇰🇷",
        "southkorea": "🇰🇷",
        "cotedivoire": "🇨🇮",
        "ivorycoast": "🇨🇮",
        "czechrepublic": "🇨🇿",
        "turkey": "🇹🇷",
        "congodr": "🇨🇩",
        "drcongo": "🇨🇩",
        "bosniaandherzegovina": "🇧🇦",
        "capeverdeislands": "🇨🇻",
        "chinapr": "🇨🇳",
        "kosovo": "🇽🇰"
    ]

    /// İngiliscə ölkə adı → ISO kodu, sistemin öz siyahısından bir dəfə qurulur.
    private static let codesByName: [String: String] = {
        let english = Locale(identifier: "en_US")
        var result: [String: String] = [:]
        for code in Locale.Region.isoRegions.map(\.identifier) where code.count == 2 {
            if let name = english.localizedString(forRegionCode: code) {
                result[normalize(name)] = code
            }
        }
        return result
    }()

    private static func normalize(_ name: String) -> String {
        name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .filter { $0.isLetter }
    }
}
