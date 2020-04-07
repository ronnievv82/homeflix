//
//  TVChannel.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 05/04/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation

enum TVStation: CaseIterable {
    case ceskaTelevize, prima, nova, joj, markiza

    var name: String {
        switch self {
        case .ceskaTelevize: return "Ceska televize"
        case .prima: return "Prima"
        case .joj: return "JOJ"
        case .markiza: return "Markiza"
        case .nova: return "Nova"
        default: return "🔥 SET MY NAME 🔥"
        }
    }

    var defaultChanngels: [TVChannel] {
        switch self {
            case .prima: return [
                TVChannel(id: "prima-cool", name: "Prima Cool",
                          currentProgramme: TVProgramme(
                            previewImageUrl: "https://cool.iprima.cz/sites/all/themes/prima_channels/images/logos/logo-cool-cover.jpg",
                            title: nil, isVod: "",
                            streamLink: "http://92.62.234.223/104/mystream.m3u8"
                ))
            ]
            default: return []
        }
    }
}

struct TVChannel: Hashable {

    // MARK: - Public properties

    let id: String
    let name: String

    let currentProgramme: TVProgramme

    // MARK: - Hashable

    static func == (lhs: TVChannel, rhs: TVChannel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TVProgramme {
    let previewImageUrl: String
    let title: String?
    let isVod: String
    let streamLink: String?
}
