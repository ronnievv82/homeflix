//
//  ShowsView.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 01/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import SwiftUI

struct ShowsView: View {
    var body: some View {
        Text("Shows").font(.title).tabItem({ Text("Shows") })
    }
}

struct ShowsView_Previews: PreviewProvider {
    static var previews: some View {
        ShowsView()
    }
}
