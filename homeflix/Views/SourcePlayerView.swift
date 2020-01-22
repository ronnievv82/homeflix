//
//  SourcePlayerView.swift
//  homeflix
//
//  Created by Martin Púčik on 09/09/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import SwiftUI

struct SourcePlayerView: View {
    let source: URL
    
    var body: some View {
        VideoView(url: source)
        
//            .navigationBarItems(trailing: Button(action: {}, label: { Text("Clsoe") }))
    }
}

struct SourcePlayerView_Previews: PreviewProvider {
    static var previews: some View {
        SourcePlayerView(source: URL(string: "")!)
    }
}
