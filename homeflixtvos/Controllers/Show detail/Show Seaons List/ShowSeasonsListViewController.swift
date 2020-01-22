//
//  ShowSeasonsListViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 12/01/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import UIKit
import Combine

private enum Section {
    case main
}

final class ShowSeasonsListViewController: UIViewController {

    @Published private(set) var selectedSeason: Season?

    private let show: Show
    @Published private var seasons: [Season] = []
    private let bag: CancelBag = CancelBag()

    init(show: Show) {
        self.show = show
        super.init(nibName: nil, bundle: nil)
        TraktvService.seasons(for: show).assign(to: \.seasons, on: self).dispose(bag)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        $seasons.sink { [weak self] seas in
            guard let self = self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<Section, Season>()
            snapshot.appendSections([.main])
            snapshot.appendItems(seas)
            self.dataSource.apply(snapshot)
        }.dispose(bag)
    }

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.delegate = self
        view.register(SeasonTableViewCell.self, forCellReuseIdentifier: "myCell")
        return view
    }()

    private lazy var dataSource: UITableViewDiffableDataSource<Section, Season> = {
        return UITableViewDiffableDataSource<Section, Season>(tableView: tableView) { (table, path, seas) -> UITableViewCell? in
            let cell = table.dequeueReusableCell(withIdentifier: "myCell", for: path)
            if let cell = cell as? SeasonTableViewCell {
                cell.textLabel?.text = seas.title
                cell.detailTextLabel?.text = "Episodes: \(seas.episode_count)"
            }
            return cell
        }
    }()
}

extension ShowSeasonsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let season = seasons[indexPath.row]
        selectedSeason = season
    }
}
