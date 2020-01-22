//
//  TMDBService.swift
//  homeflix
//
//  Created by Martin Púčik on 12/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation
import Combine

private enum TMDB {
    static let apiKey = "5fdfbd7bdff835b9fd496c671ab2930d"
    static let base = "https://api.themoviedb.org/3"
    static let tv = "/tv"
    static let person = "/person"
    static let images = "/images"
    static let season = "/season"
    static let episode = "/episode"
}

final class TMDBService {
    enum MediaType: String {
        case movie, tv
    }

    static func getPosterFor(mediaType: TMDBService.MediaType, tmdb: String) -> AnyPublisher<URL?, Never> {
        let path: String = "/\(mediaType.rawValue)/\(tmdb)\(TMDB.images)?api_key=\(TMDB.apiKey)"
        return URLSession.shared
            .dataTaskPublisher(for: request(path: path))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .map { $0.data }
            .map { data in
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
                let posters = json["posters"] as? [[String: Any]]
                let firstPath = posters?.first?["file_path"] ?? ""
                return URL(string: "https://image.tmdb.org/t/p/w400\(firstPath)")
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    static func getBackdropFor(mediaType: TMDBService.MediaType, tmdb: String) -> AnyPublisher<URL?, Never> {
        let path: String = "/\(mediaType.rawValue)/\(tmdb)\(TMDB.images)?api_key=\(TMDB.apiKey)"
        return URLSession.shared
            .dataTaskPublisher(for: request(path: path))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .map { $0.data }
            .map { data in
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
                let posters = json["backdrops"] as? [[String: Any]]
                let firstPath = posters?.first?["file_path"] ?? ""
                return URL(string: "https://image.tmdb.org/t/p/w1280\(firstPath)")
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    /**
     Load season posters from TMDB. Either a tmdb id or an imdb id must be passed in.

     - Parameter ofShowWithImdbId:  The imdb id of the show. If show hasn't get recieved it's tmdb id it will be requested using this imdb id.
     - Parameter orTMDBId:          The tmdb id of the show.
     - Parameter season:            The season of the show.

     - Parameter completion:    The completion handler for the request containing an optional tmdb id, image and an optional error.
     */
//    open func getSeasonPoster(ofShowWithImdbId imdb: String? = nil, orTMDBId tmdb: Int? = nil, season: Int, completion: @escaping (Int?, String?, NSError?) -> Void) {
//
//        guard let id = tmdb else {
//            guard let id = imdb else { completion(nil, nil, nil); return }
//            TraktManager.shared.getTMDBId(forImdbId: id, completion: { (tmdb, error) in
//                guard let tmdb = tmdb else { completion(nil, nil, error); return }
//                self.getSeasonPoster(orTMDBId: tmdb, season: season, completion: completion)
//            })
//            return
//        }
//
//        self.manager.request(TMDB.base + TMDB.tv + "/\(id)" + TMDB.season + "/\(season)" + TMDB.images, parameters: TMDB.defaultHeaders).validate().responseJSON { (response) in
//            guard let value = response.result.value else { completion(id, nil, response.result.error as NSError?); return }
//            let responseDict = JSON(value)
//
//            var image: String?
//            if let poster = responseDict["posters"].first?.1["file_path"].string {
//                image = "https://image.tmdb.org/t/p/w500" + poster
//            }
//            completion(id, image, nil)
//        }
//    }

    /**
     Load episode screenshots from TMDB. Either a tmdb id or an imdb id must be passed in.

     - Parameter forShowWithImdbId: The imdb id of the show that the episode is in. If show hasn't get recieved it's tmdb id it will be requested using this imdb id.
     - Parameter orTMDBId:          The tmdb id of the show.
     - Parameter season:            The season number of the episode.
     - Parameter episode:           The episode number of the episode.

     - Parameter completion:        The completion handler for the request containing an optional tmdb id, largeImageUrl and an optional error.
     */
//    open func getEpisodeScreenshots(forShowWithImdbId imdb: String? = nil, orTMDBId tmdb: Int? = nil, season: Int, episode: Int, completion: @escaping (Int?, String?, NSError?) -> Void) {
//
//        guard let id = tmdb else {
//            guard let id = imdb else { completion(nil, nil, nil); return }
//            TraktManager.shared.getTMDBId(forImdbId: id, completion: { (tmdb, error) in
//                guard let tmdb = tmdb else { completion(nil, nil, error); return }
//                self.getEpisodeScreenshots(orTMDBId: tmdb, season: season, episode: episode, completion: completion)
//            })
//            return
//        }
//
//        self.manager.request(TMDB.base + TMDB.tv + "/\(id)" + TMDB.season + "/\(season)" + TMDB.episode + "/\(episode)" + TMDB.images, parameters: TMDB.defaultHeaders).validate().responseJSON { (response) in
//            guard let value = response.result.value else { completion(id, nil, response.result.error as NSError?); return }
//            let responseDict = JSON(value)
//
//            var image: String?
//            if let screenshot = responseDict["stills"].first?.1["file_path"].string {
//                image = "https://image.tmdb.org/t/p/w1280" + screenshot
//            }
//            completion(id, image, nil)
//        }
//    }
}

private extension TMDBService {
    static func request(path: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "\(TMDB.base)\(path)")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

}
