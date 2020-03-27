//
//  TVViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 13/03/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import UIKit
import Combine
import SWXMLHash
import MPUtilsUIKit
import AVKit

final class TVViewController: UIViewController {

    struct Channel {
        let id: String
        let title: String
        let previewImageUrl: String
        let isVod: String
    }

    struct Playlist {
        let main: String
        let timeshift: String?
    }

    private let BASE_XML_URL = "https://www.ceskatelevize.cz"
    private var token: String = ""
    private lazy var bag: Set<AnyCancellable> = Set()
    private lazy var channels: [Channel] = []
    private var playlist: Playlist? {
        didSet {
            DispatchQueue.main.async {
                let player = AVPlayer(url: URL(string: self.playlist!.main)!)
                let cnt = AVPlayerViewController()
                cnt.player = player
                self.present(cnt, animated: true, completion: nil)
                player.play()
            }
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "TV", image: UIImage(systemName: "tv"), tag: 0)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(becameActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.channels = []
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getToken().sink(receiveValue: { [weak self] (token) in
            self?.token = token
            self?.fetchPrograms()
        }).store(in: &bag)
    }

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.delegate = self
        view.dataSource = self
        view.registerCell(UITableViewCell.self)
        return view
    }()
}

extension TVViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.textLabel?.text = channels[indexPath.row].title
        return cell
    }
}

extension TVViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        getPlaylist(channel: channel)
    }
}

private extension TVViewController {
    func getToken() -> AnyPublisher<String, Never> {
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
                let channels = xml["programmes"].children.compactMap { child -> Channel? in
                    guard
                        let id = child["live"]["programme"]["ID"].element?.text,
                        !id.isEmpty,
                        let title = child["live"]["programme"]["channelTitle"].element?.text,
                        !title.isEmpty,
                        let preview = child["live"]["programme"]["imageURL"].element?.text,
                        let isVod = child["live"]["programme"]["isVod"].element?.text
                    else {
                        return nil
                    }
//                    print(child["live"]["programme"])
//                    print("\n\n")
                    return Channel(id: id, title: title, previewImageUrl: preview, isVod: isVod)
                }

                self?.channels = channels
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }).store(in: &bag)
    }

    func getPlaylist(channel: Channel) {
        var req2 = URLRequest(url: URL(string: "\(BASE_XML_URL)/services/ivysilani/xml/playlisturl/")!)
        req2.allHTTPHeaderFields = ["Content-type": "application/x-www-form-urlencoded",
                                    "Accept-encoding": "gzip",
                                    "Connection": "Keep-Alive",
                                    "User-Agent": "Dalvik/1.6.0 (Linux; U; Android 4.4.4; Nexus 7 Build/KTU84P)"]
        req2.httpMethod = "POST"
        let quality: String = channel.isVod == "1" ? "max720p" : "web"
        let playerType: String = channel.isVod == "1" ? "progressive" : "ios"
        let params = [
            "token": token,
            "ID": channel.id,
            "quality": quality,
            "playerType": playerType,
            "playlistType": "json"
        ]
        req2.httpBody = params.percentEncoded()
        URLSession.shared.dataTaskPublisher(for: req2)
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
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] (data, _) in
                let obj = try? JSONSerialization.jsonObject(with: data)
                if let obj = obj as? [String: Any],
                    let arr = obj["playlist"] as? [[String: Any]],
                    let play = arr.first?["streamUrls"] as? [String: Any],
                    let main = play["main"] as? String {
                    let time = play["timeshift"] as? String
                    self?.playlist = Playlist(main: main, timeshift: time)
                }
            })
            .store(in: &bag)
    }

    @objc func becameActive() {
        self.channels = []
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.getToken().sink(receiveValue: { [weak self] (token) in
                self?.token = token
                self?.fetchPrograms()
            }).store(in: &self.bag)
        }
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
