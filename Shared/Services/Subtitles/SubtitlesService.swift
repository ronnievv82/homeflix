//
//  SubtitlesService.swift
//  homeflix
//
//  Created by Martin Púčik on 02/01/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation
import Combine

private enum OpenSubtitles {
    static let base = "https://rest.opensubtitles.org/"
    static let userAgent = "Popcorn Time v1"
    static let search = "search/"
    static let defaultHeaders = ["User-Agent": OpenSubtitles.userAgent]
}

final class SubtitlesService {
    static func search(imdbId: String? = nil, videoFilePath: URL? = nil) -> AnyPublisher<[Subtitle], Error> {
        let req = request(params: getParams(imdbId: imdbId, videoFilePath: videoFilePath))
        return URLSession.shared.dataTaskPublisher(for: req)
            .map { $0.data }
            .decode(type: [Subtitle].self, decoder: JSONDecoder())
            .map { $0.sorted(by: { $0.downloadCount > $1.downloadCount })}
            .print()
            .eraseToAnyPublisher()
    }

    private static func getParams(imdbId: String? = nil, preferredLang: String? = "eng", videoFilePath: URL? = nil, limit: String = "500") -> [String: Any] {
        var params: [String: Any] = ["sublanguageid": preferredLang ?? "all"]

        if let videoFilePath = videoFilePath {
            let videohash = OpenSubtitlesHash.hashFor(videoFilePath)
            params["moviehash"] = videohash.fileHash
            params["moviebytesize"] = videohash.fileSize
        }

        if let imdbId = imdbId {
            params["imdbid"] = imdbId.replacingOccurrences(of: "tt", with: "")
        }
//        else if let episode = episode {
//            params["episode"] = String(episode.episode)
//            params["query"] = episode.title
//            params["season"] = String(episode.season)
//        }
        return params
    }

    private static func request(params: [String: Any]) -> URLRequest {
        let path = OpenSubtitles.base+OpenSubtitles.search+params.compactMap({"\($0)-\($1)"}).joined(separator: "/")
        var req = URLRequest(url: URL(string: path)!)
        req.allHTTPHeaderFields = OpenSubtitles.defaultHeaders
        return req
    }
}
