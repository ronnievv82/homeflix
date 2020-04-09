//
//  Show.swift
//  homeflix
//
//  Created by Martin Púčik on 07/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation

private enum CodingKeys: String, CodingKey {
    case show, title, year, ids, imdb, trakt, tmdb
}

final class Show: MediaItem, Decodable {

    // MARK: - Lifecycle
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let movieContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .show)
        let name = try movieContainer.decode(String.self, forKey: .title)
        let yearInt = try movieContainer.decode(Int.self, forKey: .year)
        let year = "\(yearInt)"

        let idsContainer = try movieContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .ids)
        let imdbID = try idsContainer.decode(String.self, forKey: .imdb)
        let idInt = try idsContainer.decode(Int.self, forKey: .trakt)
        let id = "\(idInt)"
        let tmdbIDInt = try idsContainer.decode(Int.self, forKey: .tmdb)
        let tmdbID = "\(tmdbIDInt)"
        super.init(id: id, name: name, imdbID: imdbID, tmdbID: tmdbID, year: year)
    }

    init(searchResult: TraktSearchResult) {
        super.init(id: searchResult.id, name: searchResult.title,
                   imdbID: searchResult.imdbID, tmdbID: searchResult.tmdbID,
                   year: searchResult.year)
    }
}
