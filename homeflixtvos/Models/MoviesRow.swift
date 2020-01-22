//
//  MoviesRow.swift
//  homeflix
//
//  Created by Martin Púčik on 01/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation

final class MoviesRow: Identifiable {
    let id: String = UUID().uuidString
    let movies: [Movie]

    init(movies: [Movie]) {
        self.movies = movies
    }
}
