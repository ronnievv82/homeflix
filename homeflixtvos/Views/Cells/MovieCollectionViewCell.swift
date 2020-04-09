//
//  MovieCollectionViewCell.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 12/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import UIKit
import TVUIKit
import Kingfisher
import Combine

final class MovieCollectionViewCell: UICollectionViewCell {

    private var bag = CancelBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        bag = CancelBag()
        imageView.kf.cancelDownloadTask()
        imageView.image = UIImage(named: "poster")
    }

    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "poster"))
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 12
        view.backgroundColor = .black
        view.adjustsImageWhenAncestorFocused = false
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var card: TVCardView = {
        let view = TVCardView(frame: .zero)
        view.cardBackgroundColor = .clear
        view.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        view.footerView = TVLockupHeaderFooterView()
        view.footerView?.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        view.footerView?.showsOnlyWhenAncestorFocused = true
        return view
    }()


    // MARK: - Public methods

    func update(media: MediaItem) {
        card.footerView?.titleLabel?.text = media.name
        if let tmdb = media.tmdbID {
            TMDBService.getPosterFor(mediaType: media is Movie ? .movie : .tv, tmdb: tmdb)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] url in
                    self?.imageView.kf.setImage(with: url, options: [.backgroundDecode])
            }.dispose(bag)
        }
    }
}

private extension MovieCollectionViewCell {
    func setupAppearance() {
        contentView.clipsToBounds = false
        contentView.addSubview(card)
        card.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
