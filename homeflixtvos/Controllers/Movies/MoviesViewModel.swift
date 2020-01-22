//
//  MoviesViewModel.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 01/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation
import Combine

final class MoviesViewModel: ObservableObject {

    // MARK: - Public properties

    @Published private(set) var movies: [Movie] = []

    // MARK: - Private properties

    private let bag: CancelBag = CancelBag()

    // MARK: - Lifecycle

    init() {
        load()
    }
}

private extension MoviesViewModel {
    func load() {
        TraktvService.trendingMovies().receive(on: DispatchQueue.main)
            .assign(to: \.movies, on: self).dispose(bag)

//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
//            TraktvService.trendingMovies().receive(on: DispatchQueue.main)
//                .subscribe(self.movies).dispose(self.bag)
//        }
    }
}
