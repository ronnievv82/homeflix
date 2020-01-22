//
//  MovieDetailView.swift
//  homeflix
//
//  Created by Martin Púčik on 06/09/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import SwiftUI
import Combine

struct MovieDetailView: View {
    let movie: Movie
    
    @State private var searchCancel: AnyCancellable? = nil
    @State private var results: [SearchResult] = []
    @State private var linkCancel: AnyCancellable? = nil
    @State private var isModal: Bool = false

    var body: some View {
        List {
            Section(header: Text("Results")) {
                ForEach(results) { result in
                    Button(action: {
                        self.isModal = true
                    }, label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(result.name)")
                            Text("\(result.url.absoluteString)").font(Font.caption)
                        }
                    }).sheet(isPresented: self.$isModal, content: { SourcePlayerView(source: result.url) })
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(movie.name)
        .navigationBarItems(trailing: Button(action: {
            self.search()
        }, label: { Text("Reload") }))
        .onAppear {
            self.search()
        }
    }
}

private extension MovieDetailView {
    func search() {
        self.searchCancel = MovistackParser.search(title: movie.name, year: "\(movie.year)").replaceError(with: [])
                            .assign(to: \.results, on: self)
    }
}
