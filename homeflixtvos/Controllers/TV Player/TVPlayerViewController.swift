//
//  TVPlayerViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 09/04/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import Combine

final class TVPlayerViewController: UIViewController {

    private let channel: TVChannel
    private var bag = Set<AnyCancellable>()

    private lazy var mediaPlayer: MediaPlayer = {
        let player = MediaPlayer()
        player.drawable = view
        player.media = VLCMedia(url: URL(string: channel.currentProgramme.streamLink!)!)
        player.delegate = self
        player.audio.passthrough = true
        return player
    }()

    init(channel: TVChannel) {
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        mediaPlayer.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mediaPlayer.stop()
    }
}

extension TVPlayerViewController: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        if mediaPlayer.isPlaying, !mediaPlayer.audioTrackIndexes.isEmpty {
            mediaPlayer.currentAudioTrackIndex = mediaPlayer.audioTrackIndexes.last as! Int32
        }
    }
}
