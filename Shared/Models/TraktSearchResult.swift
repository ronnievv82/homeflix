//
//  TraktSearchResult.swift
//  homeflix
//
//  Created by Martin Púčik on 27/03/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation

struct TraktSearchResult: Decodable {

    enum ResultType: String, Decodable {
        case movie
        case show
    }

    // MARK: - Public properties

    let id: Int
    let imdbID: String?
    let tmdbID: Int?

    let type: ResultType
    let title: String
    let year: Int

    private enum Keys: CodingKey {
        case type
        case movie, show
        case title, year
        case ids, trakt, imdb, tmdb
    }

    // MARK: - Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let type = try container.decode(ResultType.self, forKey: .type)
        self.type = type

        let typeContainer: KeyedDecodingContainer<TraktSearchResult.Keys>
        switch type {
        case .movie:
            typeContainer = try container.nestedContainer(keyedBy: Keys.self, forKey: .movie)
        case .show:
            typeContainer = try container.nestedContainer(keyedBy: Keys.self, forKey: .show)
        }

        title = try typeContainer.decode(String.self, forKey: .title)
        year = try typeContainer.decode(Int.self, forKey: .year)

        let idsContainer = try typeContainer.nestedContainer(keyedBy: Keys.self, forKey: .ids)
        id = try idsContainer.decode(Int.self, forKey: .trakt)
        imdbID = try idsContainer.decodeIfPresent(String.self, forKey: .imdb)
        tmdbID = try idsContainer.decodeIfPresent(Int.self, forKey: .tmdb)
    }
}
