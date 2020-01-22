//
//  MovistackParser.swift
//  homeflix
//
//  Created by Martin Púčik on 09/09/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation
import Combine

final class MovistackParser {
    private static let base: String = "https://www.movistack.com/api"
    
    static func search(title: String, year: String) -> AnyPublisher<[SearchResult], Never> {
        let urlString = "\(title)"
            .replacingOccurrences(of: ":", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        let request = URLRequest(url: URL(string: "\(base)/search?q=\(urlString)")!)
        let aa = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .replaceError(with: Data())
            .flatMap({ data -> AnyPublisher<[SearchResult], Never> in
                guard
                    let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                    let results = json["results"] as? [[String: Any]]
                else {
                    return Just<[SearchResult]>([]).eraseToAnyPublisher()
                }
                
                for res in results {
                    guard
                        let restitle = res["title"] as? String,
                        let resdate = res["release_date"] as? String,
                        restitle == title,
                        resdate.contains(year),
                        let resID = res["id"]
                    else {
                        continue
                    }

                    let req = URLRequest(url: URL(string: "\(base)/get-movie/links/\(resID)")!)
                    return URLSession.shared.dataTaskPublisher(for: req)
                        .map { $0.data }
                        .map { data -> [SearchResult] in
                            guard
                                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                            let links = json["movieLinks"] as? [[String: Any]]
                            else {
                                return []
                            }
                            
                            var results: [SearchResult] = []
                            for link in links {
                                guard
                                    let linkUrl = link["url"] as? String,
                                    let href = link["href"],
                                    let url = URL(string: "\(linkUrl)\(href)")
                                else {
                                    continue
                                }
                                
                                let name = (link["movie_name"] as? String ?? "").removingPercentEncoding ?? ""
                                let result = SearchResult(url: url, name: name, host: url.host ?? "", searchSource: .movistack)
                                results.append(result)
                            }

                            return results
                        }
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
                }
                
                return AnyPublisher.init(Just<[SearchResult]>([]))
            })
        
        return aa.eraseToAnyPublisher()
    }
    
}
