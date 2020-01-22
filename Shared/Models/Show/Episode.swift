//
//  Episode.swift
//  homeflix
//
//  Created by Martin Púčik on 15/01/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation

struct Episode: Decodable, Hashable {
    let number: Int
    let season: Int
    let title: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(number)
    }

    var formattedSeasonEpisode: String {
        let seasonString = season > 9 ? "\(season)" : "0\(season)"
        let episodeString = number > 9 ? "\(number)" : "0\(number)"
        return "S\(seasonString)E\(episodeString)"
    }
}
