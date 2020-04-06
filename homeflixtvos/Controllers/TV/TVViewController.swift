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

    // MARK: - Private properties

    private let BASE_XML_URL = "https://www.ceskatelevize.cz"
    private var token: String = ""
    private lazy var bag: Set<AnyCancellable> = Set()

    private var sections: [TVStation: [TVChannel]] = [:]

    // MARK: - Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "TV", image: UIImage(systemName: "tv"), tag: 0)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }

        NotificationCenter.default.addObserver(self, selector: #selector(becameActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getToken().sink(receiveValue: { [weak self] (token) in
            self?.token = token
            self?.fetchPrograms()
        }).store(in: &bag)
    }

    // MARK: - Private properties

    private lazy var dataSource: UICollectionViewDiffableDataSource<TVStation, TVChannel> = {
        let source = UICollectionViewDiffableDataSource<TVStation, TVChannel>(collectionView: collectionView) { (collection, path, channel) -> UICollectionViewCell? in
            let cell = collection.dequeueReusableCell(forIndexPath: path) as ChannelCollectionViewCell
            cell.channel = channel
            return cell
        }

        source.supplementaryViewProvider = { (collection, kind, indexPath) -> UICollectionReusableView? in
            let view = collection.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            if let header = view as? TVHeaderView {
                header.tvStation = Array(self.sections.keys)[safe: indexPath.section]
            }
            return view
        }
        return source
    }()

    private lazy var layout: UICollectionViewCompositionalLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/4), heightDimension: .fractionalWidth(1/4*0.75))
        let groupItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let sectionSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let sectionGroup = NSCollectionLayoutGroup.horizontal(layoutSize: sectionSize, subitems: [groupItem])
        let section = NSCollectionLayoutSection(group: sectionGroup)

        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let sectionHeaderItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading)
        section.boundarySupplementaryItems = [sectionHeaderItem]

        return UICollectionViewCompositionalLayout(section: section)
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.clipsToBounds = false
        view.delegate = self
        view.delaysContentTouches = false
        view.registerCell(ChannelCollectionViewCell.self)
        view.register(TVHeaderView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: "header")
        return view
    }()
}

extension TVViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let section = Array(sections.keys)[safe: indexPath.section], section == .ceskaTelevize {
            let channel = sections[section]?[indexPath.row]
            getPlaylist(channel: channel!)
        }
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

                let channels = xml["programmes"].children.compactMap { child -> TVChannel? in
                    guard
                        let name = child["live"]["programme"]["channelTitle"].element?.text,
                        !name.isEmpty,
                        let preview = child["live"]["programme"]["imageURL"].element?.text,
                        let isVod = child["live"]["programme"]["isVod"].element?.text,
                        let title = child["live"]["programme"]["title"].element?.text
                    else {
                        return nil
                    }
                    return TVChannel(id: name, name: name, currentProgramme: TVProgramme(previewImageUrl: preview, title: title, isVod: isVod))
                }

                self?.sections[TVStation.ceskaTelevize] = channels
                self?.reloadSnapshot()
            }).store(in: &bag)
    }

    func getPlaylist(channel: TVChannel) {
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

                    self?.startStream(link: main)
                }
            })
            .store(in: &bag)
    }

    @objc func becameActive() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.getToken().sink(receiveValue: { [weak self] (token) in
                self?.token = token
                self?.fetchPrograms()
            }).store(in: &self.bag)
        }
    }

    func reloadSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<TVStation, TVChannel>()
        for section in TVStation.allCases {
            snapshot.appendSections([section])
            snapshot.appendItems(sections[section] ?? [], toSection: section)
        }
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        }
    }

    func startStream(link: String) {
        DispatchQueue.main.async {
            let player = AVPlayer(url: URL(string: link)!)
            let cnt = AVPlayerViewController()
            cnt.player = player
            self.present(cnt, animated: true, completion: nil)
            player.play()
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
