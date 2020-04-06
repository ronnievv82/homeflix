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
                card.footerView?.titleLabel?.text = "\(channel.name) - \(channel.currentProgramme.title)"
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
    
    private lazy var card: TVCardView = {
        let view = TVCardView()
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
