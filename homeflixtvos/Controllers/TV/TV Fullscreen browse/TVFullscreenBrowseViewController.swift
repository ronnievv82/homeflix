//
//  TVFullscreenBrowseViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 12/04/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation
import UIKit
import TVUIKit
import Combine

final class TVFullscreenBrowseViewController: UICollectionViewController {

    // MARK: - Private properties

    private let viewModel: TVViewModel
    private var selectedIndexPath: IndexPath?
    private var bag: Set<AnyCancellable> = Set()

    private let layout: TVCollectionViewFullScreenLayout = {
        let layout = TVCollectionViewFullScreenLayout()
        layout.interitemSpacing = 10
        return layout
    }()

    // MARK: - Lifecycle

    init(viewModel: TVViewModel, selectedIndexPath: IndexPath) {
        self.viewModel = viewModel
        self.selectedIndexPath = selectedIndexPath
        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        menuGesture.addToView(view)
        collectionView.registerCell(ChannelFullScreenCollectionCell.self)

        viewModel.$sections.sink { [weak self] (_) in
            self?.reloadSnapshot()
        }.store(in: &bag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let index = selectedIndexPath else { return }
        let scrollIndex = IndexPath(item: index.item+1, section: index.section)
        selectedIndexPath = scrollIndex
        collectionView.scrollToItem(at: scrollIndex, at: .centeredHorizontally, animated: false)
        collectionView.updateFocusIfNeeded()
        selectedIndexPath = nil
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.7) {
            self.layout.maskAmount = 0
        }
    }

    override func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        return selectedIndexPath
    }

    // MARK: - Private properties

    private lazy var dataSource: UICollectionViewDiffableDataSource<TVStation, TVChannel> = {
        let source = UICollectionViewDiffableDataSource<TVStation, TVChannel>(collectionView: collectionView) { (collection, path, channel) -> UICollectionViewCell? in
            let cell = collection.dequeueReusableCell(forIndexPath: path) as ChannelFullScreenCollectionCell
            cell.channel = channel
            return cell
        }
        return source
    }()

    private lazy var menuGesture: SiriRemoteMenuGesture = SiriRemoteMenuGesture { [weak self] in
        if self?.layout.maskAmount == 0 {
            UIView.animate(withDuration: 0.7) {
                self?.layout.maskAmount = 1
            }
        } else {
            self?.dismiss(animated: true, completion: nil)
        }
    }
}

private extension TVFullscreenBrowseViewController {
    func reloadSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<TVStation, TVChannel>()
        for section in TVStation.allCases {
            snapshot.appendSections([section])
            snapshot.appendItems(viewModel.sections[section] ?? [], toSection: section)
        }
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }

    func startStream(channel: TVChannel) {
        DispatchQueue.main.async {
            let cnt = TVPlayerViewController(channel: channel)
            self.present(cnt, animated: true, completion: nil)
        }
    }
}
