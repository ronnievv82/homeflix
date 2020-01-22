//
//  AVVideoPlayerView.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 11/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import SwiftUI
import AVKit
import PopcornTorrent

struct AVVideoPlayerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = AVPlayerViewController

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<AVVideoPlayerView>) -> AVVideoPlayerView.UIViewControllerType {
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
        let player = AVPlayer(url: url)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)

        // Create a new AVPlayerViewController and pass it a reference to the player.
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        player.play()
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<AVVideoPlayerView>) {

    }

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        PTTorrentStreamer.shared().cancelStreamingAndDeleteData(true)
    }
}
