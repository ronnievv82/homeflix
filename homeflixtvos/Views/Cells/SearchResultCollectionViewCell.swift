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

            if let year = result.year {
                titleLabel.text = result.title + " (\(year))"
            } else {
                titleLabel.text = result.title
            }

            guard let tmdb = result.tmdbID else {
                imageView.image = placeholder
                return
            }

            let type: TMDBService.MediaType = result.type == .movie ? .movie : .tv
            TMDBService.getBackdropFor(mediaType: type, tmdb: "\(tmdb)")
                .receive(on: DispatchQueue.main)
                .sink { [weak self] url in
                    if let url = url {
                        self?.imageView.kf.setImage(with: url, placeholder: self?.placeholder, options: [.backgroundDecode])
                    } else {
                        TMDBService.getPosterFor(mediaType: type, tmdb: "\(tmdb)")
                            .receive(on: DispatchQueue.main)
                            .sink { [weak self] url in
                                self?.imageView.kf.setImage(with: url, placeholder: self?.placeholder, options: [.backgroundDecode])
                            }.store(in: &self!.bag)
                    }
                }.store(in: &bag)
        }
    }


    // MARK: - Private properties

    private lazy var bag: Set<AnyCancellable> = Set()
    private lazy var placeholder: UIImage = UIImage(named: "poster")!

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        searchResult = nil
    }

    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: placeholder)
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.adjustsImageWhenAncestorFocused = true
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        return label
    }()
}

private extension SearchResultCollectionViewCell {
    func setupAppearance() {
        addSubview(imageView)
        addSubview(titleLabel)

        imageView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(titleLabel.snp.top).offset(-20)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.greaterThanOrEqualTo(20)
        }
    }
}
