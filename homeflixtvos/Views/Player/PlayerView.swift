//
//  PlayerView.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 11/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import SwiftUI
import PopcornTorrent
import AVKit

struct PlayerView: View {
    let mediaItem: MediaItemProtocol
    let torrent: YTSTorrent

    @State private var url: URL?
    @State private var status: PTTorrentStatus?

    var body: some View {
        makeView()
            .sheet(item: $url, content: { AVVideoPlayerView(url: $0).padding(-20) })
            .onAppear {
                self.startStream()
            }
    }
}

private extension PlayerView {
    func startStream() {
        let magnet = MagnetLinker.magnet(torrent)
        PTTorrentStreamer.shared().startStreaming(fromMultiTorrentFileOrMagnetLink: magnet, progress: { status in
            print(status)
            self.status = status
        }, readyToPlay: { url, _ in
            print(url)
            self.url = url
        }, failure: { error in
            print(error)
        }, selectFileToStream: { files -> Int32 in
            print(files)
            return 0
        })
    }

    func makeView() -> AnyView {
        if let _ = url {
            return AnyView(Text("Playing..."))
        }

        if let status = status {
            let buffer = Int(status.bufferingProgress * 100)
            return AnyView(VStack {
                Text("Loading ...").font(.subheadline)
                Text("\(mediaItem.name)").font(Font.title)
                Text("Buffering: \(buffer)% ").font(Font.caption)
            })
        }

        return AnyView(VStack {
            Text("Loading ...").font(.subheadline)
            Text("\(mediaItem.name)").font(Font.title)
        })
    }
}

extension URL: Identifiable {
    public var id: String { return absoluteString }
}
