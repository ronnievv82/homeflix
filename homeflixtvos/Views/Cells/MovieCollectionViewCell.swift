//
//  MovieCollectionViewCell.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 12/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import UIKit
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
        view.adjustsImageWhenAncestorFocused = true
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Public methods

    func update(media: MediaItem) {
        titleLabel.text = media.name
        TMDBService.getPosterFor(mediaType: media is Movie ? .movie : .tv, tmdb: media.tmdbID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                self?.imageView.kf.setImage(with: url, options: [.backgroundDecode])
            }.dispose(bag)
    }
}

private extension MovieCollectionViewCell {
    func setupAppearance() {
        clipsToBounds = false
        addSubview(titleLabel)
        addSubview(imageView)

        imageView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(8)
        }
    }
}
