//
//  AnyCancellableExtension.swift
//  homeflix
//
//  Created by Martin Púčik on 07/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Combine

extension AnyCancellable {
    func dispose(_ bag: CancelBag) {
        bag.insert(self)
    }
}
