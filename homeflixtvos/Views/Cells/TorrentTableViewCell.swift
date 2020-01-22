//
//  TorrentTableViewCell.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 22/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import UIKit

final class TorrentTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
//        setupAppearance()
    }

    required init?(coder: NSCoder) { nil }

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()

    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        return label
    }()

    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let view = UIVisualEffectView(effect: effect)
        return view
    }()

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)

        coordinator.addCoordinatedFocusingAnimations({ (con) in

        }, completion: {
            context.nextFocusedView?.backgroundColor = .clear
            self.backgroundColor = .clear
            self.contentView.backgroundColor = .clear
            self.backgroundView?.backgroundColor = .clear
            self.selectedBackgroundView?.backgroundColor = .clear
        })

//        contentView.backgroundColor = isFocused ? .black : .clear
        context.nextFocusedView?.backgroundColor = .clear
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundView?.backgroundColor = .clear
        selectedBackgroundView?.backgroundColor = .clear
    }

    func update(torrent: Torrent) {
        nameLabel.text = torrent.name
        descLabel.text = "\(torrent.size)  ➡️  S: \(torrent.seeds) | L: \(torrent.peers)"
    }
}

private extension TorrentTableViewCell {
    func setupAppearance() {
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.addSubview(blurView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descLabel)

        blurView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        nameLabel.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        descLabel.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview().inset(16)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
        }
    }
}
