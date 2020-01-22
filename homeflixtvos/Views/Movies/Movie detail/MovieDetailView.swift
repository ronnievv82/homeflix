//
//  MovieDetailView.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 02/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import SwiftUI
import Combine

struct MovieDetailView: View {
    let movie: Movie

    @State private var torrents: [YTSTorrent] = []
    @State private var selectedTorrent: YTSTorrent?
    private let bag: CancelBag = CancelBag()

    var body: some View {
        VStack(alignment: .leading) {
            Text(movie.name).font(.title).bold()
            List(torrents) { tor in
                Button(action: {
                    self.selectedTorrent = tor
                }) {
                    VStack(alignment: .leading) {
                        Text("\(tor.type): \(tor.quality) - \(tor.size)").font(.subheadline)
                        Text("S:\(tor.seeds) L:\(tor.peers)").font(.footnote)
                    }
                }.sheet(item: self.$selectedTorrent) { PlayerView(mediaItem: self.movie, torrent: $0) }
            }
        }
        .onAppear {
            self.loadTorrents()
        }
    }
}

private extension MovieDetailView {
    func loadTorrents() {
        YTSService.torrents(item: movie).assign(to: \.torrents, on: self).dispose(bag)
    }
}
