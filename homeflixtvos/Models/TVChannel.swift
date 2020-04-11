//
//  TVChannel.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 05/04/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation

enum TVStation: CaseIterable {
    case ceskaTelevize, prima, nova, joj, markiza, rtvs, eurosport, hbo

    var name: String {
        switch self {
        case .ceskaTelevize: return "Ceska televize"
        case .prima: return "Prima"
        case .joj: return "JOJ"
        case .markiza: return "Markiza"
        case .nova: return "Nova"
        case .rtvs: return "RTVS"
        case .eurosport: return "Eurosport"
        case .hbo: return "HBO"
        }
    }

    var defaultChanngels: [TVChannel] {
        switch self {
            case .prima: return [.primaCool, .primaLove, .primaMax]
            case .joj: return [.joj, .jojPlus, .jojWau, .jojFamily]
            case .nova: return [.nova, .nova2, .novaAction, .novaCinema]
            case .rtvs: return [.rtvs1, .rtvs2]
            case .markiza: return [.markiza]
            case .eurosport: return [.eurosport1]
            case .hbo: return [.hbo, .hbo2]
            default: return []
        }
    }
}

struct TVChannel: Hashable {

    // MARK: - Public properties

    let id: String
    let name: String

    var currentProgramme: TVProgramme

    mutating func updateStreamLink(_ link: String?) {
        currentProgramme.updateStreamLink(link)
    }

    // MARK: - Hashable

    static func == (lhs: TVChannel, rhs: TVChannel) -> Bool {
        return lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

extension TVChannel {
    static var primaCool: TVChannel {
        let programme = TVProgramme(
            preview: "https://cool.iprima.cz/sites/all/themes/prima_channels/images/logos/logo-cool-cover.jpg",
            streamLink: "http://92.62.234.223/104/mystream.m3u8"
        )
        return TVChannel(id: "prima-cool", name: "Prima Cool", currentProgramme: programme)
    }
    static var primaLove: TVChannel {
        let programme = TVProgramme(
            preview: "https://cool.iprima.cz/sites/all/themes/prima_channels/images/logos/logo-love-cover.jpg",
            streamLink: "http://92.62.234.223/101/mystream.m3u8"
        )
        return TVChannel(id: "prima-love", name: "Prima Love", currentProgramme: programme)
    }
    static var primaMax: TVChannel {
        let programme = TVProgramme(
            preview: "https://cool.iprima.cz/sites/all/themes/prima_channels/images/logos/logo-max-cover.jpg",
            streamLink: "http://70.32.0.9:5000/live/518/playlist.m3u8"
        )
        return TVChannel(id: "prima-max", name: "Prima Max", currentProgramme: programme)
    }
    static var joj: TVChannel {
        let programme = TVProgramme(
            preview: "https://fontech.startitup.sk/wp-content/uploads/2017/04/tv-joj_2.jpg",
            streamLink: "http://nn2.joj.sk/hls/joj-720.m3u8"
        )
        return TVChannel(id: "joj", name: "JOJ", currentProgramme: programme)
    }
    static var jojPlus: TVChannel {
        let programme = TVProgramme(
            preview: "https://upload.wikimedia.org/wikipedia/commons/3/39/TV_JOJ_Plus_logo.jpg",
            streamLink: "http://nn2.joj.sk/hls/jojplus-540.m3u8"
        )
        return TVChannel(id: "joj-plus", name: "JOJ plus", currentProgramme: programme)
    }
    static var jojWau: TVChannel {
        let programme = TVProgramme(
            preview: "http://mediaboom.sk/wp-content/uploads/2014/05/wau_televizia_kanal_stanica_joj_logo.jpg",
            streamLink: "http://nn2.joj.sk/hls/wau-540.m3u8"
        )
        return TVChannel(id: "joj-wau", name: "JOJ wau", currentProgramme: programme)
    }
    static var jojFamily: TVChannel {
        let programme = TVProgramme(
            preview: "https://i.iinfo.cz/images/399/joj-family-1.jpg",
            streamLink: "http://nn2.joj.sk/hls/family-540.m3u8"
        )
        return TVChannel(id: "joj-fam", name: "JOJ family", currentProgramme: programme)
    }
    static var nova: TVChannel {
        let programme = TVProgramme(
            preview: "https://www.wic-net.cz/wp-content/uploads/2017/01/logo-televize-nova-2017-600x388.png",
            streamLink: "https://nova-live.ssl.cdn.cra.cz/channels/nova_avod/playlist/cze/live_hq.m3u8"
        )
        return TVChannel(id: "nova", name: "Nova", currentProgramme: programme)
    }
    static var nova2: TVChannel {
        let programme = TVProgramme(
            preview: "https://static.cz.prg.cmestatic.com/static/cz/main/img/site_logo/mix/logo_site_81000.jpg",
            streamLink: "https://nova-live.ssl.cdn.cra.cz/channels/nova_2_avod/playlist/cze/live_hq.m3u8"
        )
        return TVChannel(id: "nova2", name: "Nova 2", currentProgramme: programme)
    }
    static var novaAction: TVChannel {
        let programme = TVProgramme(
            preview: "https://img.ihned.cz/attachment.php/750/66738750/B4oQdsLRE7u1h0pIJnvxrKAF9SNm2zUc/1280x720xc141/logo-stanice-nova-action-drive-fanda-2017.png",
            streamLink: "https://nova-live.ssl.cdn.cra.cz/channels/nova_action_avod/playlist/cze/live_hq.m3u8"
        )
        return TVChannel(id: "nova-action", name: "Nova Action", currentProgramme: programme)
    }
    static var novaCinema: TVChannel {
        let programme = TVProgramme(
            preview: "https://static.cz.prg.cmestatic.com/static/cz/main/img/site_logo/mix/logo_site_86000.jpg",
            streamLink: "https://nova-live.ssl.cdn.cra.cz/channels/nova_cinema_avod/playlist/cze/live_hq.m3u8"
        )
        return TVChannel(id: "nova-cinema", name: "Nova Cinema", currentProgramme: programme)
    }
    static var eurosport1: TVChannel {
        let programme = TVProgramme(
            preview: "http://www.itver.cc/wp-content/uploads/2015/07/Eurosport-HD-Logo.jpg",
            streamLink: "http://188.35.9.14:21081/udp/098t"
        )
        return TVChannel(id: "eurosport1", name: "Eurosport 1 HD", currentProgramme: programme)
    }
    static var rtvs1: TVChannel {
        let programme = TVProgramme(
            preview: "https://milk.sk/gallery/quicktaste/thumbs/rtvs_4.jpg",
            streamLink: "https://ocko-live.ssl.cdn.cra.cz/channels/stv1/playlist/cze/live_hd.m3u8"
        )
        return TVChannel(id: "rtvs1", name: "Jednotka", currentProgramme: programme)
    }
    static var rtvs2: TVChannel {
        let programme = TVProgramme(
            preview: "https://milk.sk/gallery/quicktaste/thumbs/rtvs_3.jpg",
            streamLink: "https://ocko-live.ssl.cdn.cra.cz/channels/stv2/playlist/cze/live_hd.m3u8"
        )
        return TVChannel(id: "rtvs2", name: "Dvojka", currentProgramme: programme)
    }
    static var markiza: TVChannel {
        let programme = TVProgramme(
            preview: "https://androidportal.zoznam.sk/wp-content/uploads/2016/11/29/markiza-logo.jpg",
            streamLink: "https://ocko-live.ssl.cdn.cra.cz/channels/markiza/playlist/cze/live_hd.m3u8"
        )
        return TVChannel(id: "markiza", name: "Markiza", currentProgramme: programme)
    }

    static var hbo: TVChannel {
        let programme = TVProgramme(
            preview: "https://www.tvweek.com/wp-content/uploads/2015/03/hbo-logo.jpg",
            streamLink: "http://188.35.9.11:21151/udp/190z"
        )
        return TVChannel(id: "hbo", name: "HBO", currentProgramme: programme)
    }
    static var hbo2: TVChannel {
        let programme = TVProgramme(
            preview: "https://www.tvweek.com/wp-content/uploads/2015/03/hbo-logo.jpg",
            streamLink: "http://188.35.9.11:21151/udp/157a"
        )
        return TVChannel(id: "hbo2", name: "HBO 2", currentProgramme: programme)
    }

}


struct TVProgramme {
    let previewImageUrl: String
    let title: String?
    let isVod: String
    var streamLink: String?

    init(preview: String, title: String? = nil, isVod: String = "0", streamLink: String? = nil) {
        self.previewImageUrl = preview
        self.title = title
        self.isVod = isVod
        self.streamLink = streamLink
    }

    mutating func updateStreamLink(_ link: String?) {
        self.streamLink = link
    }
}
