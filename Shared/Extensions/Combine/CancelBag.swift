//
//  CancelBag.swift
//  homeflix
//
//  Created by Martin Púčik on 07/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Combine

final class CancelBag {
    private var _disposables = [AnyCancellable]()

    func insert(_ disposable: AnyCancellable) {
        _disposables.append(disposable)
    }
}
