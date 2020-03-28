//
//  TraktvService.swift
//  homeflix
//
//  Created by Martin Púčik on 04/09/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation
import Combine

enum TService {
    case trendingMovies

}

final class TraktvService {
    private static let clientId: String = "1f96e8204bc08e8ce4fb388d70456330541eeeb19909992ce424d4cb3eca77b4"
    private static let clientSecret: String = "9005394a7ed727a385560e3add17bca5ba7ca58dd9cf3c5fd7bc89d7d0fa5214"
    
    static let base: String = "https://api.trakt.tv"
    
    static func trendingMovies() -> AnyPublisher<[Movie], Never> {
        return URLSession.shared.dataTaskPublisher(for: request(path: "/movies/trending?limit=30"))
            .map { $0.data }
            .decode(type: [Movie].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    static func trendingShows() -> AnyPublisher<[Show], Never> {
        return URLSession.shared.dataTaskPublisher(for: request(path: "/shows/trending?limit=30"))
            .map { $0.data }
            .decode(type: [Show].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    static func seasons(for show: Show) -> AnyPublisher<[Season], Never> {
        return URLSession.shared.dataTaskPublisher(for: request(path: "/shows/\(show.id)/seasons?extended=full"))
        .map { $0.data }
        .decode(type: [Season].self, decoder: JSONDecoder())
        .mapError { error -> Error in
            print(error)
            return error
        }
        .replaceError(with: [])
        .eraseToAnyPublisher()
    }

    static func episodes(for show: Show, season: Season) -> AnyPublisher<[Episode], Never> {
        return URLSession.shared.dataTaskPublisher(for: request(path: "/shows/\(show.id)/seasons/\(season.number)/episodes"))
        .map { $0.data }
        .decode(type: [Episode].self, decoder: JSONDecoder())
        .mapError { error -> Error in
            print(error)
            return error
        }
        .replaceError(with: [])
        .eraseToAnyPublisher()
    }

    static func search(_ query: String) -> AnyPublisher<[TraktSearchResult], Never> {
        return URLSession.shared.dataTaskPublisher(for: request(path: "/search/movie,show?query=\(query)"))
            .map { $0.data }
            .decode(type: [TraktSearchResult].self, decoder: JSONDecoder())
            .mapError { error -> Error in
                print(error)
                return error
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

private extension TraktvService {
    static func request(path: String) -> URLRequest {
        let fullPath = base + path
        let escapedPath = fullPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var request = URLRequest(url: URL(string: escapedPath)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2", forHTTPHeaderField: "trakt-api-version")
        request.setValue(clientId, forHTTPHeaderField: "trakt-api-key")
        return request
    }
}
