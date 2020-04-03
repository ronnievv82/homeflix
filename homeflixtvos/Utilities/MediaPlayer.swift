//
//  MediaPlayer.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 22/01/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation

final class MediaPlayer: VLCMediaPlayer {

    override init() {
        super.init()

        audio.passthrough = true
        setupSubtitleAppearance()
        setEqualizerProfile(.fullDynamicRange)
    }


    // MARK: - Public methods

    func setupSubtitleAppearance() {
        let settings = SubtitleSettings.shared
        (self as VLCFontAppearance).setTextRendererFontSize?(NSNumber(value: settings.size.rawValue))
        (self as VLCFontAppearance).setTextRendererFontColor?(NSNumber(value: settings.color.hexInt))
        (self as VLCFontAppearance).setTextRendererFont?(settings.font.fontName as NSString)
        let forceBold = settings.style == .bold || settings.style == .boldItalic
        (self as VLCFontAppearance).setTextRendererFontForceBold?(NSNumber(booleanLiteral: forceBold))
        if let media = media {
            media.addOptions(["subsdec-encoding": settings.encoding])
        }
    }

    func setEqualizerProfile(_ profile: EqualizerProfiles) {
        resetEqualizer(fromProfile: profile.rawValue)
        equalizerEnabled = true
    }
}
