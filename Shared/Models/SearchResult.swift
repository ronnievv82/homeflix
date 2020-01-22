//
//  SearchResult.swift
//  homeflix
//
//  Created by Martin Púčik on 04/09/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation

enum SearchSource {
    case ololo
    case movistack
}

struct SearchResult {
    let url: URL
    let name: String
    let host: String
    let searchSource: SearchSource
}

extension SearchResult: Identifiable {
    typealias ID = String
    
    var id: String {
        return url.absoluteString
    }
}
