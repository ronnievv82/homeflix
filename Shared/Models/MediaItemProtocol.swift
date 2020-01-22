//
//  MediaItemProtocol.swift
//  homeflix
//
//  Created by Martin Púčik on 07/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation

protocol MediaItemProtocol {

    var id: String { get }
    var name: String { get }
    var imdbID: String { get }
    var tmdbID: String { get }
    var year: String { get }
}
