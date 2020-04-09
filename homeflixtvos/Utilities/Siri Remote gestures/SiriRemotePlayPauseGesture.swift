//
//  SiriRemotePlayPauseGesture.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 22/01/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation

final class SiriRemotePlayPauseGesture {
    // MARK: - Public properties
    typealias ActionClosure = () -> Void

    // MARK: - Private properties
    private let actionClosure: ActionClosure

    // MARK: - Lifecycle
    init(actionClosure: @escaping ActionClosure) {
        self.actionClosure = actionClosure
    }

    // MARK: - Private properties
    private lazy var recognizer: UITapGestureRecognizer = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(playPauseAction))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue),
                                           NSNumber(value: UIPress.PressType.select.rawValue)]
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
