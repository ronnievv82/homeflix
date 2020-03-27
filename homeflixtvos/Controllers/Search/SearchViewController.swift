//
//  SearchViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 21/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import Foundation
import UIKit
import MPUtils
import Combine

final class SearchViewController: UISearchContainerViewController {

    init() {
        let resultController = SearchResultViewController()
        let search = UISearchController(searchResultsController: resultController)
        super.init(searchController: search)
        tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        searchController.searchResultsUpdater = resultController
    }

    required init?(coder: NSCoder) { nil }
}

final class SearchResultViewController: UIViewController {

    private var searchRequest: AnyCancellable?
    private var results: [TraktSearchResult] = []
    private var searchedQuery: String = ""

    // MARK: - Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Private properties

    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 80
        layout.minimumInteritemSpacing = 80
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        view.dataSource = self
        view.delegate = self
        view.contentInset = UIEdgeInsets(top: 40, left: 80, bottom: 12, right: 80)
        view.register(SearchResultCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return view
    }()
}

extension SearchResultViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viableWidth = collectionView.bounds.width - 160 - 2 * 80
        return CGSize(width: viableWidth / 3, height: 300)
    }
}

extension SearchResultViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SearchResultCollectionViewCell
        cell?.searchResult = results[indexPath.row]
        return cell!
    }
}

// MARK: - UISearchResultsUpdating

extension SearchResultViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard
            let query = searchController.searchBar.text?.trimmed,
            query.count > 2,
            query != searchedQuery
        else {
            return
        }

        searchRequest?.cancel()
        searchedQuery = query
        searchRequest = TraktvService.search(searchedQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.results = results
                self?.collectionView.reloadData()
        }
    }
}
