//
//  MatchDetailData.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 30.09.26.
//
import UIKit

struct MatchDetailData {
    let competitionName: String
    let homeName: String
    let awayName: String
    let homeCrest: UIImage?
    let awayCrest: UIImage?
    let score: String
    let minuteOrStatus: String
    let stats: [MatchStatsView.Stat]
    let formationName: String
    let formation: LineUpView.Formation
    let headToHead: HeadToHead
}
