//
//  ChannelFullScreenCollectionCell.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 12/04/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation
import UIKit
import TVUIKit
import MediaPlayer
import Combine
import SWXMLHash

final class ChannelFullScreenCollectionCell: TVCollectionViewFullScreenCell {

    // MARK: - Public properties

    var channel: TVChannel? {
        didSet {
            if let channel = channel, let preview = URL(string: channel.currentProgramme.previewImageUrl) {
                imageView.kf.setImage(with: preview)
            } else {
                imageView.image = UIImage(imageLiteralResourceName: "poster")
            }
        }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupAppearance()
        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        channel = nil
        mediaPlayer = nil
        streamLinkCancellable?.cancel()
        streamLinkCancellable = nil
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)

        if isFocused {
            startPlayback()
        } else {
            mediaPlayer?.stop()
            mediaPlayer = nil
        }
    }

    // MARK: - Private properties

    private let BASE_XML_URL = "https://www.ceskatelevize.cz"
    private var mediaPlayer: MediaPlayer?
    private var streamLinkCancellable: AnyCancellable?
    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: UIImage(imageLiteralResourceName: "poster"))
        view.contentMode = .scaleAspectFill
        return view
    }()
}

// MARK: - Private methods

private extension ChannelFullScreenCollectionCell {
    func setupAppearance() {
        maskedBackgroundView.addSubview(imageView)
    }

    func setupConstraints() {
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func startPlayback() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard self.isFocused else { return }
            self.streamLinkCancellable = self.getStreamChannel().sink { [weak self] link in
                guard
                    let link = self?.channel?.currentProgramme.streamLink,
                    let url = URL(string: link)
                    else { return }
                self?.mediaPlayer = MediaPlayer()
                self?.mediaPlayer?.drawable = self?.maskedBackgroundView
                self?.mediaPlayer?.media = VLCMedia(url: url)
                self?.mediaPlayer?.play()
            }
        }
    }

    func getStreamChannel() -> AnyPublisher<String?, Never> {
        guard let channel = channel else { return Just(nil).eraseToAnyPublisher() }
        switch channel.station {
            case .ceskaTelevize:
                return getToken().flatMap { self.getPlaylist(token: $0, channel: channel) }.eraseToAnyPublisher()
            default:
                return Just(channel.currentProgramme.previewImageUrl).eraseToAnyPublisher()
        }
    }

    func getToken(force: Bool = false) -> AnyPublisher<String, Never> {
        let TOKEN_URL = "\(BASE_XML_URL)/services/ivysilani/xml/token/"

        var req = URLRequest(url: URL(string: TOKEN_URL)!)
        req.allHTTPHeaderFields = ["Content-Type": "application/x-www-form-urlencoded"]
        req.httpMethod = "POST"
        req.httpBody = "user=iDevicesMotion".data(using: .utf8)

        return URLSession.shared.dataTaskPublisher(for: req).compactMap({ (data, _) -> String? in
            let str = String(data: data, encoding: .utf8)!
            let startToken = str.range(of: "n>")!.upperBound
            let endToken = str.range(of: "</token")!.lowerBound
            return String(str[startToken..<endToken])
        }).replaceError(with: "").eraseToAnyPublisher()
    }

    func getPlaylist(token: String, channel: TVChannel) -> AnyPublisher<String?, Never> {
        var req2 = URLRequest(url: URL(string: "\(BASE_XML_URL)/services/ivysilani/xml/playlisturl/")!)
        req2.allHTTPHeaderFields = ["Content-type": "application/x-www-form-urlencoded",
                                    "Accept-encoding": "gzip",
                                    "Connection": "Keep-Alive",
                                    "User-Agent": "Dalvik/1.6.0 (Linux; U; Android 4.4.4; Nexus 7 Build/KTU84P)"]
        req2.httpMethod = "POST"
        let quality: String = channel.currentProgramme.isVod == "1" ? "max720p" : "web"
        let playerType: String = channel.currentProgramme.isVod == "1" ? "progressive" : "ios"
        let params = [
            "token": token,
            "ID": channel.id,
            "quality": quality,
            "playerType": playerType,
            "playlistType": "json"
        ]
        req2.httpBody = params.percentEncoded()
        return URLSession.shared.dataTaskPublisher(for: req2)
            .compactMap { (data, _) -> URL? in
                let xml = SWXMLHash.parse(data)
                print(xml)
                let string = xml["playlistURL"].element?.text ?? ""
                return URL(string: string)
        }
        .flatMap({ url -> URLSession.DataTaskPublisher in
            var req = URLRequest(url: url)
            req.allHTTPHeaderFields = ["Content-Type": "application/json"]
            req.httpMethod = "GET"
            return URLSession.shared.dataTaskPublisher(for: req)
        })
        .compactMap { data -> String? in
            let obj = try? JSONSerialization.jsonObject(with: data.data)
            if let obj = obj as? [String: Any],
                let arr = obj["playlist"] as? [[String: Any]],
                let play = arr.first?["streamUrls"] as? [String: Any],
                let main = play["main"] as? String {

                DispatchQueue.main.async {
                    self.channel?.updateStreamLink(main)
                }
                return main
            }
            return nil
        }
        .replaceError(with: nil)
        .eraseToAnyPublisher()
    }
}
