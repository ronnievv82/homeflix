//
//  MoviesViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 11/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import UIKit
import Combine
import SnapKit

private enum Section {
    case main
}

final class MoviesViewController: UIViewController {

    private let viewModel: MoviesViewModel
    private let bag: CancelBag = CancelBag()

    init(viewModel: MoviesViewModel = MoviesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Movies", image: nil, tag: 0)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(40)
        }

        viewModel.$movies.sink { [weak self] mov in
            guard let self = self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
            snapshot.appendSections([.main])
            snapshot.appendItems(mov)
            self.dataSource.apply(snapshot)
        }.dispose(bag)
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Movie> = {
        return UICollectionViewDiffableDataSource<Section, Movie>(collectionView: collectionView) { (collection, path, movie) -> UICollectionViewCell? in
            let cell = collection.dequeueReusableCell(withReuseIdentifier: "myCell", for: path)
            if let cell = cell as? MovieCollectionViewCell {
                cell.update(media: movie)
            }
            return cell
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.clipsToBounds = false
        view.delegate = self
        view.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "myCell")
        return view
    }()
}

extension MoviesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: width * 1.5)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = viewModel.movies[indexPath.row]
        let vm = MovieDetailViewModel(movie: movie)
        present(MovieDetailViewController(viewModel: vm), animated: true, completion: nil)
    }
}
