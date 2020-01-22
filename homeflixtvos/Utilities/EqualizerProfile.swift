//
//  EqualizerProfile.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 22/01/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation

enum EqualizerProfiles: UInt32 {
    case fullDynamicRange = 0
    case reduceLoudSounds = 15

    static let array = [fullDynamicRange, reduceLoudSounds]

    var localizedString: String {
        switch self {
        case .fullDynamicRange: return "Full Dynamic Range"
        case .reduceLoudSounds: return "Reduce Loud Sounds"
        }
    }
}
