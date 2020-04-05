//
//  ContentProvider.swift
//  topshelf
//
//  Created by Martin Púčik on 05/04/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import TVServices

final class ContentProvider: TVTopShelfContentProvider {

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        // Fetch content and call completionHandler
        completionHandler(
            TVTopShelfCarouselContent(style: .details, items: [
                TVTopShelfCarouselItem(identifier: "AA")
            ])
        );
    }
}
