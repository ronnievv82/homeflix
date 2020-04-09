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

    let id: String
    let imdbID: String?
    let tmdbID: String?

    let type: ResultType
    let title: String
    let year: String?

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
        if let yearInt = try typeContainer.decodeIfPresent(Int.self, forKey: .year) {
            year = "\(yearInt)"
        } else {
            year = nil
        }

        let idsContainer = try typeContainer.nestedContainer(keyedBy: Keys.self, forKey: .ids)
        let id = try idsContainer.decode(Int.self, forKey: .trakt)
        self.id = "\(id)"

        imdbID = try idsContainer.decodeIfPresent(String.self, forKey: .imdb)
        if let tmdbID = try idsContainer.decodeIfPresent(Int.self, forKey: .tmdb) {
            self.tmdbID = "\(tmdbID)"
        } else {
            tmdbID = nil
        }
    }
}
