//
//  ChannelCollectionViewCell.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 05/04/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation
import UIKit
import TVUIKit

final class ChannelCollectionViewCell: UICollectionViewCell {
    var channel: TVChannel? {
        didSet {
            if let channel = channel {
                if let programmeTitle = channel.currentProgramme.title, programmeTitle.isNotEmpty {
                    card.footerView?.titleLabel?.text = "\(channel.name) - \(programmeTitle)"
                } else {
                    card.footerView?.titleLabel?.text = channel.name
                }

                if let preview = URL(string: channel.currentProgramme.previewImageUrl) {
                    imageView.kf.setImage(with: preview)
                }
            } else {
                card.footerView?.titleLabel?.text = nil
                imageView.image = nil
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        channel = nil
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [card.contentView]
    }

    private lazy var card: TVCardView = {
        let view = TVCardView()
        view.contentViewInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: -5, trailing: 0)
        view.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        view.footerView = TVLockupHeaderFooterView()
        view.footerView?.titleLabel?.enablesMarqueeWhenAncestorFocused = true
        view.footerView?.showsOnlyWhenAncestorFocused = false
        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: UIImage(imageLiteralResourceName: "poster"))
        view.contentMode = .scaleAspectFill
        return view
    }()
}

private extension ChannelCollectionViewCell {
    func setupAppearance() {
        contentView.addSubview(card)
    }

    func setupConstraints() {
        card.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
