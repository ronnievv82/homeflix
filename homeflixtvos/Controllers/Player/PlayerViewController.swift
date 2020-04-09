//
//  PlayerViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 20/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import UIKit
import AVKit
import Combine
import MediaPlayer

final class PlayerViewController: UIViewController {

    // MARK: - Private properties

    private let media: MediaItem
    private let torrent: Torrent

    private lazy var streamer: PTTorrentStreamer = PTTorrentStreamer()

    @Published private var subtitles: [Subtitle] = []
    private var selectedSubtitle: Subtitle?

    private let bag: CancelBag = CancelBag()

    private var readyToPlay: Bool = false

    // MARK: - Lifecycle
    
    init(torrent: Torrent, media: MediaItem) {
        self.torrent = torrent
        self.media = media
        super.init(nibName: nil, bundle: nil)

        let magnet = MagnetLinker.magnet(torrent)
        streamer.startStreaming(fromMultiTorrentFileOrMagnetLink: magnet, progress: { [weak self] (status) in
            self?.updateProgress(status: status)
        }, readyToPlay: { [weak self] (url, fileUrl) in
            DispatchQueue.main.async {
                self?.play(url: fileUrl)
//                self?.loadSubtitles(fileURL: fileUrl)
            }
        }, failure: { [weak self] (err) in
            print(err)
            self?.dismiss(animated: true, completion: nil)
        }, selectFileToStream: { (files) -> Int32 in
            print(files)
            let file = files.first(where: { $0.contains("mp4") || $0.contains("mkv") || $0.contains("avi") }) ?? ""
            return Int32(files.firstIndex(of: file) ?? 0)
        })

        SubtitlesService.search(imdbId: media.imdbID).assign(to: \.subtitles, on: self).dispose(bag)
    }

    required init?(coder: NSCoder) { nil }

    deinit {
        mediaPlayer.delegate = nil
        mediaPlayer.stop()
        streamer.cancelStreamingAndDeleteData(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }

    private lazy var playPauseRecognizer: SiriRemotePlayPauseGesture = {
        SiriRemotePlayPauseGesture { [weak self] in
            (self?.mediaPlayer.isPlaying ?? false) ? self?.mediaPlayer.pause() : self?.mediaPlayer.play()
        }
    }()

    private lazy var swipeDownRecognizer: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownAction))
        gesture.direction = .down
        return gesture
    }()

    private lazy var swipeUpRecognizer: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpAction))
        gesture.direction = .up
        return gesture
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "--:--"
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        return label
    }()

    private lazy var playerView: UIView = UIView()
    private lazy var mediaPlayer: MediaPlayer = MediaPlayer()
//    private lazy var progressView: UIView = UIView()
//    private lazy var progressBar: ProgressBar = ProgressBar(frame: .zero)
    private var infoView: PlayerInfoView?
    private var loadingView: PlayerLoadingView?// = PlayerLoadingView(media: media, streamer: streamer)
}

private extension PlayerViewController {
    func setupAppearance() {
        playPauseRecognizer.addToView(view)
        view.addGestureRecognizer(swipeDownRecognizer)
        view.addGestureRecognizer(swipeUpRecognizer)

        let loading = PlayerLoadingView(media: media, streamer: streamer)
        view.addSubview(loading)
        loading.snp.makeConstraints { $0.edges.equalToSuperview() }
        self.loadingView = loading

//        view.addSubview(progressView)
//        progressView.addSubview(progressBar)
//        progressView.addSubview(timeLabel)

//        progressView.alpha = 0
//        progressView.snp.makeConstraints { $0.bottom.leading.trailing.equalToSuperview().inset(20) }
//
//        progressBar.snp.makeConstraints { (make) in
//            make.centerY.leading.equalToSuperview()
//            make.height.equalTo(12)
//        }
//
//        timeLabel.snp.makeConstraints { (make) in
//            make.top.trailing.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-2)
//            make.width.equalTo(150)
//            make.leading.equalTo(progressBar.snp.trailing)
//        }

        let gesture = SiriRemoteGestureRecognizer(target: self, action: #selector(touchLocationDidChange(_:)))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)

        let clickGesture = SiriRemoteGestureRecognizer(target: self, action: #selector(clickGesture(_:)))
        clickGesture.delegate = self
        view.addGestureRecognizer(clickGesture)
    }

    func play(url: URL) {
        view.addSubview(playerView)
        playerView.snp.makeConstraints { $0.edges.equalToSuperview() }

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        mediaPlayer.delegate = self
        mediaPlayer.drawable = playerView
        mediaPlayer.media = VLCMedia(url: url)
        mediaPlayer.play()

//        playerView.alpha = 1
//        progressBar.alpha = 1

        loadingView?.removeFromSuperview()
        loadingView = nil
    }

    func loadSubtitles(fileURL: URL?) {
        subtitles.first?.download().sink(receiveCompletion: { _ in }, receiveValue: { [weak self] url in
//            self?.mediaPlayer.addPlaybackSlave(url, type: .subtitle, enforce: true)
        }).dispose(bag)
    }

    @objc func swipeDownAction() {
        guard infoView == nil else { return }
        let info = PlayerInfoView()
        view.addSubview(info)

        info.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.4)
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        infoView = info
    }

    @objc func swipeUpAction() {
//        infoView?.removeFromSuperview()
//        infoView = nil
    }

    @objc func touchLocationDidChange(_ gesture: SiriRemoteGestureRecognizer) {
        if gesture.state == .ended {
//            hideInfoLabel()
        } else if gesture.isLongTap {
//            showInfoLabel()
        }

//        progressBar.hint = .none
//        resetIdleTimer()

//        guard !progressBar.isScrubbing && mediaPlayer.isPlaying && !progressBar.isHidden && !progressBar.isBuffering else { return }

//        switch gesture.touchLocation {
//        case .left:
//            if gesture.isClick && gesture.state == .ended { rewind(); progressBar.hint = .none }
//            if gesture.isLongPress { rewindHeld(gesture) } else if gesture.state != .ended { progressBar.hint = .jumpBackward30 }
//        case .right:
//            if gesture.isClick && gesture.state == .ended { fastForward(); progressBar.hint = .none }
//            if gesture.isLongPress { fastForwardHeld(gesture) } else if gesture.state != .ended { progressBar.hint = .jumpForward30 }
//        default: return
//        }
    }

    @objc func clickGesture(_ gesture: SiriRemoteGestureRecognizer) {
        guard gesture.touchLocation == .unknown && gesture.isClick && gesture.state == .ended else {
//            progressBar.isHidden ? toggleControlsVisible() : ()
            return
        }

//        guard !progressBar.isScrubbing else {
//            endScrubbing()
            if mediaPlayer.isSeekable {
//                let time = NSNumber(value: progressBar.scrubbingProgress * streamDuration)
//                mediaPlayer.time = VLCTime(number: time)
                // Force a progress change rather than waiting for VLCKit's delegate call to.
//                progressBar.progress = progressBar.scrubbingProgress
//                progressBar.elapsedTimeLabel.text = progressBar.scrubbingTimeLabel.text
            }
//            return
//        }

        mediaPlayer.canPause ? mediaPlayer.pause() : ()
//        progressBar.isHidden ? toggleControlsVisible() : ()
//        dimmerView!.isHidden = false
//        progressBar.isScrubbing = true

//        let currentTime = NSNumber(value: progressBar.progress * streamDuration)
//        if let image = screenshotAtTime(currentTime) {
//            progressBar.screenshot = image
//        }
    }

    func updateProgress(status: PTTorrentStatus) {
        if !readyToPlay {
            loadingView?.status = status
        } else {
//            progressBar.bufferProgress = status.totalProgress
        }
    }
}

extension PlayerViewController: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification?) {
        UIView.animate(withDuration: 0.2, animations: {
//            self.progressView.alpha = 1
        }, completion: { _ in
//            if self.mediaPlayer.isPlaying {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
//                    self.progressView.alpha = 0
                }
//            }
        })
    }

    func mediaPlayerTimeChanged(_ aNotification: Notification?) {
//        progressBar.progress = mediaPlayer.position
//        timeLabel.text = mediaPlayer.remainingTime.stringValue
    }
}

extension PlayerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
