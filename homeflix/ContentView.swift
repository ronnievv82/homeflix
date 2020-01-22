//
//  ContentView.swift
//  homeflix
//
//  Created by Martin Púčik on 07/08/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import SwiftUI
import SwiftSoup
import Combine
import WebKit
 
struct ContentView: View {
    @State private var ss: AnyCancellable? = nil
    @State private var items: [Movie] = []
    
    var body: some View {
        NavigationView {
            VStack {
                Text("NEXT")
            }
            .navigationBarTitle("Trending", displayMode: .automatic)
            Text("Select ...")
        }.onAppear {
            self.ss = TraktvService.trendingMovies().assign(to: \.items, on: self)
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
