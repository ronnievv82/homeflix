//
//  SearchView.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 01/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    @State private var text: String = ""

    var body: some View {
        VStack {
            TextField("Search", text: $text)
            Spacer()
        }.tabItem({ Text("Search") })
    }
}
