//
//  ShowsViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 11/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import UIKit
import Combine

private enum Section {
    case main
}

final class ShowsViewController: UIViewController {

    @Published private(set) var shows: [Show] = []
    private let bag: CancelBag = CancelBag()

    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Shows", image: nil, tag: 1)
        TraktvService.trendingShows().receive(on: DispatchQueue.main)
            .assign(to: \.shows, on: self).dispose(bag)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(40)
        }

        $shows.sink { [weak self] show in
            guard let self = self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<Section, Show>()
            snapshot.appendSections([.main])
            snapshot.appendItems(show)
            self.dataSource.apply(snapshot)
        }.dispose(bag)
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Show> = {
        return UICollectionViewDiffableDataSource<Section, Show>(collectionView: collectionView) { (collection, path, show) -> UICollectionViewCell? in
            let cell = collection.dequeueReusableCell(withReuseIdentifier: "myCell", for: path)
            if let cell = cell as? MovieCollectionViewCell {
                cell.update(media: show)
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

extension ShowsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: width * 1.5)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let show = shows[indexPath.row]
        present(ShowDetailViewController(show: show), animated: true, completion: nil)
    }
}
