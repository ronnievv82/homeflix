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
    case loadNext
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
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }

        viewModel.$movies.sink { [weak self] mov in
            guard let self = self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
            snapshot.appendSections([.main, .loadNext])
            snapshot.appendItems(mov, toSection: .main)
            self.dataSource.apply(snapshot)
        }.dispose(bag)
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Movie> = {
        return UICollectionViewDiffableDataSource<Section, Movie>(collectionView: collectionView) { (collection, path, movie) -> UICollectionViewCell? in
            let cell = collection.dequeueReusableCell(forIndexPath: path) as MovieCollectionViewCell
            cell.update(media: movie)
            return cell
        }
    }()

    private lazy var layout: UICollectionViewCompositionalLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/6), heightDimension: .fractionalWidth(1/6*1.5))
        let groupItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let sectionSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let sectionGroup = NSCollectionLayoutGroup.horizontal(layoutSize: sectionSize, subitems: [groupItem])
        let section = NSCollectionLayoutSection(group: sectionGroup)
        return UICollectionViewCompositionalLayout(section: section)
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.clipsToBounds = false
        view.delegate = self
        view.registerCell(MovieCollectionViewCell.self)
        return view
    }()
}

// MARK: - UICollectionViewDelegate

extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = viewModel.movies[indexPath.row]
        let vm = MovieDetailViewModel(movie: movie)
        present(MovieDetailViewController(viewModel: vm), animated: true, completion: nil)
    }
}
