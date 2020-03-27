//
//  SearchResultCollectionViewCell.swift
//  homeflix
//
//  Created by Martin Púčik on 27/03/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class SearchResultCollectionViewCell: UICollectionViewCell {

    // MARK: - Public properties

    var searchResult: TraktSearchResult? {
        didSet {
            guard let result = searchResult else {
                bag = Set()
                imageView.kf.cancelDownloadTask()
                imageView.image = placeholder
                return
            }

            titleLabel.text = result.title
            TMDBService.getBackdropFor(mediaType: result.type == .movie ? .movie : .tv, tmdb: "\(result.tmdbID!)")
                .receive(on: DispatchQueue.main)
                .sink { [weak self] url in
                    self?.imageView.kf.setImage(with: url, options: [.backgroundDecode])
                }.store(in: &bag)
        }
    }


    // MARK: - Private properties

    private lazy var bag: Set<AnyCancellable> = Set()
    private lazy var placeholder: UIImage = UIImage(imageLiteralResourceName: "poster")

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = placeholder
    }

    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: placeholder)
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
}

private extension SearchResultCollectionViewCell {
    func setupAppearance() {
        clipsToBounds = false
        addSubview(imageView)
        addSubview(titleLabel)

        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }

        titleLabel.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
