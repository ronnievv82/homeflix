//
//  MediaItemProtocol.swift
//  homeflix
//
//  Created by Martin Púčik on 07/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation

class MediaItem {
    // MARK: - Public properties
    let id: String
    let name: String
    let imdbID: String?
    let tmdbID: String?
    let year: String?

    // MARK: - Lifecycle
    init(id: String, name: String, imdbID: String?, tmdbID: String?, year: String?) {
        self.id = id
        self.name = name
        self.imdbID = imdbID
        self.tmdbID = tmdbID
        self.year = year
    }
}

// MARK: - Equatable
extension MediaItem: Equatable {
    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool { lhs.id == rhs.id }
}

// MARK: - Hashable
extension MediaItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
