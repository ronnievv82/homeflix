//
//  MovieDetailViewModel.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 13/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation
import Combine

final class MovieDetailViewModel {
    let movie: Movie

    @Published private(set) var torrents: [Torrent] = []
    private let bag = CancelBag()
    
    init(movie: Movie) {
        self.movie = movie
        loadTorrents()
    }
}

private extension MovieDetailViewModel {
    func loadTorrents() {
        YTSService.torrents(item: movie).merge(with: SevenTorrentsService.torrents(item: movie))
            .collect().map { $0.reduce([], +) }
            .assign(to: \.torrents, on: self)
            .dispose(bag)
    }
}
