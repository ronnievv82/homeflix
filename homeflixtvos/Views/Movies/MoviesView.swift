//
//  MoviesView.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 01/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import SwiftUI

struct MoviesView: View {

    // MARK: - Public methods

    @ObservedObject private(set) var viewModel: MoviesViewModel

    // MARK: - Private properties

    @State private var selectedMovie: Movie?

    // MARK: - Lifecycle

    var body: some View {
        ScrollView {
//            makeRows(self.viewModel.movies)
        }.frame(minWidth: 300)
        .sheet(item: $selectedMovie, content: { MovieDetailView(movie: $0) })
        .tabItem({ Text("Movies") })
    }
}

private extension MoviesView {
    func makeRows(_ rows: [MoviesRow]) -> AnyView {
        AnyView(VStack(alignment: HorizontalAlignment.leading) {
            Text("Movies").font(.largeTitle).bold()
            ForEach(rows) { row -> AnyView in
                self.makeMoviesRow(row)
            }
        }.padding(20))
    }

    func makeMoviesRow(_ row: MoviesRow) -> AnyView {
        let stack = HStack(spacing: 20) {
            ForEach(row.movies) { movie in
                Button(action: {
                    self.selectedMovie = movie
                }, label: {
                    Text(movie.name).frame(width: 190, height: 300)
                })
            }
        }

        return AnyView(stack)
    }
}
