//
//  LineUp.swift
//  FootballApp
//
//  Created by Servan on 07.10.26.
//

import CoreGraphics

struct LineupPlayer {
    let number: Int
    let name: String
    var isCaptain = false
    var goals = 0
    var yellowCards = 0
    var isSentOff = false
}

struct TeamLineup {
    let teamName: String
    /// "4-2-3-1" kimi (qapıçı daxil deyil).
    let formation: String
    /// 11 oyunçu: əvvəl qapıçı, sonra xətlər üzrə (müdafiə → hücum), hər xətt soldan sağa.
    let players: [LineupPlayer]
}

struct MatchLineups {
    let home: TeamLineup
    let away: TeamLineup
    /// false olanda rəsmi heyət hələ elan olunmayıb, göstərilən təxmini (probable) heyətdir.
    let isConfirmed: Bool
}

/// Oyunçunun meydançadakı yeri. x: 0 (sol) … 1 (sağ), y: 0 (hücum tərəfi, yuxarı) … 1 (öz qapısı, aşağı).
struct PitchSlot {
    let player: LineupPlayer
    let x: CGFloat
    let y: CGFloat
    /// Oyunçunun xəttində neçə nəfər var (ad etiketinin maksimum enini hesablamaq üçün).
    let lineSize: Int
}

enum FormationLayout {

    private static let goalkeeperY: CGFloat = 0.85

    static func slots(for lineup: TeamLineup) -> [PitchSlot] {
        guard let goalkeeper = lineup.players.first else { return [] }

        let outfield = Array(lineup.players.dropFirst())
        let lines = parse(lineup.formation, outfieldCount: outfield.count)
        let centers = rowCenters(lineCount: lines.count)

        var slots = [PitchSlot(player: goalkeeper, x: 0.5, y: goalkeeperY, lineSize: 1)]
        var cursor = 0

        for (lineIndex, size) in lines.enumerated() {
            let xs = xPositions(count: size)
            let lift = outerLift(lineIndex: lineIndex, lineCount: lines.count, size: size)

            for position in 0..<size {
                guard cursor < outfield.count else { break }
                let isOuter = position == 0 || position == size - 1
                let y = centers[lineIndex] - (isOuter ? lift : 0)
                slots.append(PitchSlot(player: outfield[cursor], x: xs[position], y: y, lineSize: size))
                cursor += 1
            }
        }
        return slots
    }

    // MARK: - Private

    /// "4-2-3-1" → [4, 2, 3, 1]. Format yanlışdırsa və ya cəmi oyunçu sayına uyğun gəlmirsə ehtiyat variant qaytarır.
    private static func parse(_ formation: String, outfieldCount: Int) -> [Int] {
        let parts = formation.split(separator: "-").compactMap { Int($0) }
        if !parts.isEmpty, parts.allSatisfy({ $0 > 0 }), parts.reduce(0, +) == outfieldCount {
            return parts
        }
        if outfieldCount == 10 { return [4, 4, 2] }
        return outfieldCount > 0 ? [outfieldCount] : []
    }

    /// Hər xəttin mərkəz y-i (müdafiədən hücuma). 4 xətt üçün dəyərlər dizayndakı 4-2-3-1 ilə üst-üstə düşür.
    private static func rowCenters(lineCount: Int) -> [CGFloat] {
        switch lineCount {
        case 0: return []
        case 1: return [0.45]
        case 2: return [0.60, 0.16]
        case 3: return [0.64, 0.38, 0.10]
        case 4: return [0.64, 0.42, 0.22, 0.06]
        default:
            let top: CGFloat = 0.06
            let bottom: CGFloat = 0.66
            let step = (bottom - top) / CGFloat(lineCount - 1)
            return (0..<lineCount).map { bottom - step * CGFloat($0) }
        }
    }

    private static func xPositions(count: Int) -> [CGFloat] {
        switch count {
        case 1:
            return [0.5]
        case 2:
            return [0.385, 0.615]
        default:
            let margin: CGFloat
            switch count {
            case 3: margin = 0.15
            case 4: margin = 0.136
            default: margin = 0.10
            }
            let step = (1 - 2 * margin) / CGFloat(count - 1)
            return (0..<count).map { margin + step * CGFloat($0) }
        }
    }

    /// Kənar oyunçuların mərkəzdəkilərə nisbətən nə qədər irəli durması (müsbət = yuxarı).
    private static func outerLift(lineIndex: Int, lineCount: Int, size: Int) -> CGFloat {
        guard size >= 3 else { return 0 }
        let isDefense = lineIndex == 0
        let isAttack = lineIndex == lineCount - 1

        if isAttack { return size == 3 ? -0.03 : 0 }
        if isDefense { return size >= 4 ? 0.033 : 0 }
        // 4-2-3-1-dəki hücumçu yarımmüdafiəçi üçlüyü: qanadlar yuxarıda, mərkəz (10 nömrə) aşağıda.
        if lineCount == 4, lineIndex == 2, size == 3 { return 0.086 }
        return 0.04
    }
}
