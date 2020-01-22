//
//  VideoView.swift
//  homeflix
//
//  Created by Martin Púčik on 09/09/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import SwiftUI
import AVKit
import AVFoundation

struct VideoView: UIViewControllerRepresentable {
    let url: URL
    
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: Self.Context) -> UIViewControllerType {
        print(url)
        let con = AVPlayerViewController()
        con.player = AVPlayer(url: URL(string: "https://c20.vidlox.me/oudvgukrertk2yixv4u6oarbd476yc4r5zu7h3tqihyvm7rfu3w4ytgn3epq/v.mp4")!)
        con.allowsPictureInPicturePlayback = true
        return con
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<VideoView>) {
        
    }

}
//
//struct VideoView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoView()
//    }
//}
