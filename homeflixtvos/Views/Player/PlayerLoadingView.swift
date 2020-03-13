//
//  PlayerLoadingView.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 22/01/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import UIKit

final class PlayerLoadingView: UIView {
    // MARK: - Private properties
    private let media: MediaItem

    // MARK: - Lifecycle
    init(media: MediaItem) {
        self.media = media
        super.init(frame: .zero)
        setupAppearance()
        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Private properties
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        label.text = media.name
        return label
    }()

    private lazy var activity: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        view.hidesWhenStopped = true
        view.startAnimating()
        return view
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .center
        label.text = "Loading ..."
        return label
    }()
}

// MARK: - Private methods
private extension PlayerLoadingView {
    func setupAppearance() {
        addSubview(nameLabel)
        addSubview(activity)
        addSubview(statusLabel)
    }

    func setupConstraints() {
        activity.snp.makeConstraints { $0.center.equalToSuperview() }
        statusLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(activity.snp.bottom).offset(24)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(activity.snp.top).offset(-24)
        }
    }
}
