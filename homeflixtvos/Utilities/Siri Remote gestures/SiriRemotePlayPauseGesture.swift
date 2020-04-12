//
//  SiriRemotePlayPauseGesture.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 22/01/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation

class SiriRemoteGesture {
    // MARK: - Public properties
    typealias ActionClosure = () -> Void

    // MARK: - Private properties
    private let actionClosure: ActionClosure
    private let types: [UIPress.PressType]

    // MARK: - Lifecycle
    init(types: [UIPress.PressType], actionClosure: @escaping ActionClosure) {
        self.actionClosure = actionClosure
        self.types = types
    }

    // MARK: - Private properties
    private lazy var recognizer: UITapGestureRecognizer = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(playPauseAction))
        tapRecognizer.allowedPressTypes = types.compactMap { NSNumber(value: $0.rawValue) }
        return tapRecognizer
    }()

    @objc private func playPauseAction() {
        actionClosure()
    }

    // MARK: - Public methods
    func addToView(_ view: UIView) {
        view.addGestureRecognizer(recognizer)
    }
}

final class SiriRemotePlayPauseGesture: SiriRemoteGesture {
    init(actionClosure: @escaping SiriRemoteGesture.ActionClosure) {
        super.init(types: [.playPause, .select], actionClosure: actionClosure)
    }
}

final class SiriRemoteMenuGesture: SiriRemoteGesture {
    init(actionClosure: @escaping ActionClosure) {
        super.init(types: [.menu], actionClosure: actionClosure)
    }
}
