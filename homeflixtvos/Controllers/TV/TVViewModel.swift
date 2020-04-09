//
//  TVViewModel.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 06/04/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation
import Combine
import SWXMLHash

final class TVViewModel {

    @Published private(set) var sections: [TVStation: [TVChannel]] = [:]

    private let BASE_XML_URL = "https://www.ceskatelevize.cz"
    private var token: String = ""

    private lazy var bag: Set<AnyCancellable> = Set()
    
    init() {
        for sec in TVStation.allCases {
            sections[sec] = sec.defaultChanngels
        }
        fetchCT()
        NotificationCenter.default.addObserver(self, selector: #selector(becameActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    func refresh() {
        fetchCT()
    }

    func getStreamLink(index: IndexPath) -> AnyPublisher<String?, Never> {
        guard let section = TVStation.allCases[safe: index.section] else {
            return Just(nil).eraseToAnyPublisher()
        }
        switch section {
            case .ceskaTelevize:
                return getPlaylist(channel: sections[section]![index.row])
            default:
                return Just(sections[section]![index.row].currentProgramme.streamLink).eraseToAnyPublisher()
        }
    }
}

private extension TVViewModel {
    func fetchCT() {
        getToken().sink { [weak self] token in
            self?.token = token
            self?.fetchPrograms()
        }.store(in: &bag)
    }

    func getToken(force: Bool = false) -> AnyPublisher<String, Never> {
        if token.isNotEmpty, !force {
            return Just(token).eraseToAnyPublisher()
        }

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

    func fetchPrograms() {
        var req = URLRequest(url: URL(string: "\(BASE_XML_URL)/services/ivysilani/xml/programmelist/")!)
        req.allHTTPHeaderFields = ["Content-Type": "application/x-www-form-urlencoded"]
        req.httpMethod = "POST"
        req.httpBody = "token=\(token)&imageType=1280&current=1".data(using: .utf8)
        URLSession.shared.dataTaskPublisher(for: req)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] (data, _) in
                let xml = SWXMLHash.parse(data)

                let channels = xml["programmes"].children.compactMap { child -> TVChannel? in
                    guard
                        let id = child["live"]["programme"]["ID"].element?.text,
                        let name = child["live"]["programme"]["channelTitle"].element?.text,
                        !name.isEmpty,
                        let preview = child["live"]["programme"]["imageURL"].element?.text,
                        let isVod = child["live"]["programme"]["isVod"].element?.text,
                        let title = child["live"]["programme"]["title"].element?.text
                        else {
                            return nil
                    }
                    let programme = TVProgramme(previewImageUrl: preview, title: title, isVod: isVod, streamLink: nil)
                    return TVChannel(id: id, name: name, currentProgramme: programme)
                }

                self?.sections[.ceskaTelevize] = channels
            }).store(in: &bag)
    }

    func getPlaylist(channel: TVChannel) -> AnyPublisher<String?, Never> {
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

                return main
            }
            return nil
        }
        .replaceError(with: nil)
        .eraseToAnyPublisher()
    }

    @objc func becameActive() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.getToken(force: true).sink(receiveValue: { [weak self] (token) in
                self?.token = token
                self?.fetchPrograms()
            }).store(in: &self.bag)
        }
    }
}
