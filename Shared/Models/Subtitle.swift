//
//  Subtitle.swift
//  homeflix
//
//  Created by Martin Púčik on 06/01/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation
import Combine

private enum CodingKeys: CodingKey {
    case SubFileName, SubDownloadLink, SubDownloadsCnt
}

struct Subtitle: Decodable, Identifiable {
    let name: String
    let downloadString: String
    let downloadCount: Int

    var id: String { downloadString }
    
    // MARK: - Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .SubFileName)
        let initialLink: String = try container.decode(String.self, forKey: .SubDownloadLink)
        downloadString = initialLink[initialLink.startIndex..<initialLink.range(of: "download/")!.upperBound] + "subencoding-utf8/" + initialLink[initialLink.range(of: "download/")!.upperBound...]
        let downloadCountString = try container.decode(String.self, forKey: .SubDownloadsCnt)
        downloadCount = Int(downloadCountString) ?? 0
    }

    // MARK: - Public methods

    func download() -> AnyPublisher<URL, Error> {
        guard let url = URL(string: downloadString) else {
            return Fail(error: HFError.notValidURL).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .compactMap { (data, response) -> URL in
                let path = NSTemporaryDirectory().appending(url.lastPathComponent)
                let fileUrl = URL(fileURLWithPath: path)
                do {
                    try FileManager.default.createDirectory(atPath: NSTemporaryDirectory(),
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)
                    try data.write(to: fileUrl)
                } catch let error {
                    print(error)
                }
                return fileUrl
            }
            .mapError { _ in HFError.subtitleDownloadFailed }
            .eraseToAnyPublisher()
    }
}
