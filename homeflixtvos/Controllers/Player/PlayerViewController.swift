//
//  PlayerViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 20/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import UIKit
import AVKit
import PopcornTorrent
import Combine
import MediaPlayer

final class PlayerViewController: UIViewController {

    private let media: MediaItemProtocol
    private let torrent: Torrent
    private lazy var streamer: PTTorrentStreamer = PTTorrentStreamer()

    @Published private var subtitles: [Subtitle] = []
    private var selectedSubtitle: Subtitle?
    private let bag: CancelBag = CancelBag()

    init(torrent: Torrent, media: MediaItemProtocol) {
        self.torrent = torrent
        self.media = media
        super.init(nibName: nil, bundle: nil)

        let magnet = MagnetLinker.magnet(torrent)
        streamer.startStreaming(fromMultiTorrentFileOrMagnetLink: magnet, progress: { [weak self] (status) in
            let per = Int(status.bufferingProgress * 100)
            let down = self?.streamer.totalDownloaded.longLongValue ?? 0
            let totalDown = ByteCountFormatter.string(fromByteCount: down, countStyle: .decimal)
            let up = self?.streamer.totalUploaded.longLongValue ?? 0
            let totalUp = ByteCountFormatter.string(fromByteCount: up, countStyle: .decimal)
            self?.statusLabel.text = "Loading: \(per)% - D: \(totalDown) | U: \(totalUp)"
            self?.progressBar.bufferProgress = status.totalProgress
        }, readyToPlay: { [weak self] (url, fileUrl) in
            DispatchQueue.main.async {
                self?.play(url: url)
                self?.loadSubtitles(fileURL: fileUrl)
            }
        }, failure: { (err) in
            print(err)
        }) { (files) -> Int32 in
            print(files)
            let file = files.first(where: { $0.contains("mp4") || $0.contains("mkv") || $0.contains("avi") }) ?? ""
            return Int32(files.firstIndex(of: file) ?? 0)
        }

        SubtitlesService.search(imdbId: media.imdbID).replaceError(with: [])
            .assign(to: \.subtitles, on: self).dispose(bag)

//        $subtitles.filter { !$0.isEmpty }.map { $0.first! }.mapError { $0 as Error }
//            .flatMap { $0.download() }.sink(receiveCompletion: { _ in }, receiveValue: { url in
//                print(url)
//            }).dispose(bag)
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

    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(playPauseAction))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue),
                                           NSNumber(value: UIPress.PressType.select.rawValue)]
        return tapRecognizer
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

    private lazy var loadingContainer: UIView = {
        let view = UIView()
        view.addSubview(nameLabel)
        view.addSubview(activity)
        view.addSubview(statusLabel)

        activity.snp.makeConstraints { $0.center.equalToSuperview() }
        statusLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(activity.snp.bottom).offset(24)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(activity.snp.top).offset(-24)
        }
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        label.text = media.name
        return label
    }()

    private lazy var activity: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        view.hidesWhenStopped = true
        view.startAnimating()
        return view
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .center
        label.text = "Loading ..."
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "--:--"
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        return label
    }()

    private lazy var playerView: UIView = UIView()
    private lazy var mediaPlayer: VLCMediaPlayer = VLCMediaPlayer()
    private lazy var progressView: UIView = UIView()
    private lazy var progressBar: ProgressBar = ProgressBar(frame: .zero)
    private var infoView: PlayerInfoView?
}

private extension PlayerViewController {
    func setupAppearance() {
        view.addSubview(loadingContainer)
        view.addGestureRecognizer(tapRecognizer)
        view.addGestureRecognizer(swipeDownRecognizer)
        view.addGestureRecognizer(swipeUpRecognizer)

        view.addSubview(playerView)

        view.addSubview(progressView)
        progressView.addSubview(progressBar)
        progressView.addSubview(timeLabel)

        loadingContainer.snp.makeConstraints { $0.center.width.equalToSuperview() }

        playerView.alpha = 0
        playerView.snp.makeConstraints { $0.edges.equalToSuperview() }

        progressView.alpha = 0
        progressView.snp.makeConstraints { $0.bottom.leading.trailing.equalToSuperview().inset(20) }

        progressBar.snp.makeConstraints { (make) in
            make.centerY.leading.equalToSuperview()
            make.height.equalTo(12)
        }

        timeLabel.snp.makeConstraints { (make) in
            make.top.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-2)
            make.width.equalTo(150)
            make.leading.equalTo(progressBar.snp.trailing)
        }

        let gesture = SiriRemoteGestureRecognizer(target: self, action: #selector(touchLocationDidChange(_:)))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)

        let clickGesture = SiriRemoteGestureRecognizer(target: self, action: #selector(clickGesture(_:)))
        clickGesture.delegate = self
        view.addGestureRecognizer(clickGesture)
    }

    func play(url: URL) {
        loadingContainer.alpha = 0

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)

        mediaPlayer.delegate = self
        mediaPlayer.audio.passthrough = true
        mediaPlayer.drawable = playerView
        mediaPlayer.media = VLCMedia(url: url)
        mediaPlayer.play()

        let settings = SubtitleSettings.shared
        (mediaPlayer as VLCFontAppearance).setTextRendererFontSize?(NSNumber(value: settings.size.rawValue))
        (mediaPlayer as VLCFontAppearance).setTextRendererFontColor?(NSNumber(value: settings.color.hexInt))
        (mediaPlayer as VLCFontAppearance).setTextRendererFont?(settings.font.fontName as NSString)
        (mediaPlayer as VLCFontAppearance).setTextRendererFontForceBold?(NSNumber(booleanLiteral: settings.style == .bold || settings.style == .boldItalic))
        mediaPlayer.media.addOptions(["subsdec-encoding": settings.encoding])

        playerView.alpha = 1
        progressBar.alpha = 1

        didSelectEqualizerProfile(.fullDynamicRange)
    }

    func loadSubtitles(fileURL: URL?) {
        subtitles.first?.download().sink(receiveCompletion: { _ in }, receiveValue: { [weak self] url in
            self?.mediaPlayer.addPlaybackSlave(url, type: .subtitle, enforce: true)
        }).dispose(bag)
    }

    @objc func playPauseAction() {
        mediaPlayer.isPlaying ? mediaPlayer.pause() : mediaPlayer.play()
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
        infoView?.removeFromSuperview()
        infoView = nil
    }

    @objc func touchLocationDidChange(_ gesture: SiriRemoteGestureRecognizer) {
        if gesture.state == .ended {
//            hideInfoLabel()
        } else if gesture.isLongTap {
//            showInfoLabel()
        }

        progressBar.hint = .none
//        resetIdleTimer()

        guard !progressBar.isScrubbing && mediaPlayer.isPlaying && !progressBar.isHidden && !progressBar.isBuffering else { return }

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

        guard !progressBar.isScrubbing else {
//            endScrubbing()
            if mediaPlayer.isSeekable {
//                let time = NSNumber(value: progressBar.scrubbingProgress * streamDuration)
//                mediaPlayer.time = VLCTime(number: time)
                // Force a progress change rather than waiting for VLCKit's delegate call to.
                progressBar.progress = progressBar.scrubbingProgress
                progressBar.elapsedTimeLabel.text = progressBar.scrubbingTimeLabel.text
            }
            return
        }

        mediaPlayer.canPause ? mediaPlayer.pause() : ()
//        progressBar.isHidden ? toggleControlsVisible() : ()
//        dimmerView!.isHidden = false
        progressBar.isScrubbing = true

//        let currentTime = NSNumber(value: progressBar.progress * streamDuration)
//        if let image = screenshotAtTime(currentTime) {
//            progressBar.screenshot = image
//        }
    }
    func didSelectEqualizerProfile(_ profile: EqualizerProfiles) {
        mediaPlayer.resetEqualizer(fromProfile: profile.rawValue)
        mediaPlayer.equalizerEnabled = true
    }
}

extension PlayerViewController: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification?) {
        UIView.animate(withDuration: 0.2, animations: {
            self.progressView.alpha = 1
        }, completion: { _ in
            if self.mediaPlayer.isPlaying {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.progressView.alpha = 0
                }
            }
        })
    }

    func mediaPlayerTimeChanged(_ aNotification: Notification?) {
        progressBar.progress = mediaPlayer.position
        timeLabel.text = mediaPlayer.remainingTime.stringValue
    }
    
}

extension PlayerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
