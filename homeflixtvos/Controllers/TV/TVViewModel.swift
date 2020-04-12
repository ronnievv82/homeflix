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
                    let programme = TVProgramme(preview: preview, title: title, isVod: isVod)
                    return TVChannel(id: id, name: name, station: .ceskaTelevize, currentProgramme: programme)
                }

                self?.sections[.ceskaTelevize] = channels
            }).store(in: &bag)
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
