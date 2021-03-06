//
//  TVViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 13/03/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import UIKit
import Combine
import MPUtilsUIKit
import AVKit
import TVUIKit

final class TVViewController: UICollectionViewController {

    // MARK: - Private properties
    private let viewModel: TVViewModel
    private var bag: Set<AnyCancellable> = Set()

    // MARK: - Lifecycle

    init(viewModel: TVViewModel = TVViewModel()) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: layout)
        tabBarItem = UITabBarItem(title: "TV", image: UIImage(systemName: "tv"), tag: 0)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delaysContentTouches = false
        collectionView.registerCell(ChannelCollectionViewCell.self)
        collectionView.register(TVHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        viewModel.$sections.sink { [weak self] (_) in
            self?.reloadSnapshot()
        }.store(in: &bag)
    }

    // MARK: - Private properties

    private lazy var dataSource: UICollectionViewDiffableDataSource<TVStation, TVChannel> = {
        let source = UICollectionViewDiffableDataSource<TVStation, TVChannel>(collectionView: collectionView) { (collection, path, channel) -> UICollectionViewCell? in
            let cell = collection.dequeueReusableCell(forIndexPath: path) as ChannelCollectionViewCell
            cell.channel = channel
            return cell
        }

        source.supplementaryViewProvider = { (collection, kind, indexPath) -> UICollectionReusableView? in
            let view = collection.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            if let header = view as? TVHeaderView {
                header.tvStation = TVStation.allCases[safe: indexPath.section]
            }
            return view
        }
        return source
    }()

    private let layout: UICollectionViewCompositionalLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/4), heightDimension: .fractionalWidth(1/4*0.75))
        let groupItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let sectionSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let sectionGroup = NSCollectionLayoutGroup.horizontal(layoutSize: sectionSize, subitems: [groupItem])
        let section = NSCollectionLayoutSection(group: sectionGroup)
        section.orthogonalScrollingBehavior = .continuous
        
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let sectionHeaderItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading)
        section.boundarySupplementaryItems = [sectionHeaderItem]
        return UICollectionViewCompositionalLayout(section: section)
    }()


    // MARK: - Overrides

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fsvc = TVFullscreenBrowseViewController(viewModel: viewModel, selectedIndexPath: indexPath)
        present(fsvc, animated: false, completion: nil)
    }
}

private extension TVViewController {
    func reloadSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<TVStation, TVChannel>()
        for section in TVStation.allCases {
            snapshot.appendSections([section])
            snapshot.appendItems(viewModel.sections[section] ?? [], toSection: section)
        }
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        }
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
