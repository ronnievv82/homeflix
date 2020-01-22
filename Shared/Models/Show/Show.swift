//
//  Show.swift
//  homeflix
//
//  Created by Martin Púčik on 07/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation

private enum CodingKeys: String, CodingKey {
    case show
    case title
    case year
    case ids
    case imdb
    case trakt
    case tmdb
}

struct Show: Decodable, MediaItemProtocol, Hashable {
    let id: String
    let name: String
    let year: String
    let imdbID: String
    let tmdbID: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let movieContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .show)
        name = try movieContainer.decode(String.self, forKey: .title)
        let yearInt = try movieContainer.decode(Int.self, forKey: .year)
        year = "\(yearInt)"
        let idsContainer = try movieContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .ids)
        imdbID = try idsContainer.decode(String.self, forKey: .imdb)

        let id = try idsContainer.decode(Int.self, forKey: .trakt)
        self.id = "\(id)"

        let tmdbID = try idsContainer.decode(Int.self, forKey: .tmdb)
        self.tmdbID = "\(tmdbID)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
