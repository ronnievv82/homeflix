//
//  ShowEpisodesListController.swift
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

final class ShowEpisodesListController: UIViewController {

    @Published var selectedSeason: Season?
    @Published private(set) var selectedEpisode: Episode?

    @Published private var episodes: [Episode] = []

    private let show: Show
    private let bag: CancelBag = CancelBag()

    init(show: Show) {
        self.show = show
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalToSuperview().inset(40)
        }

        $selectedSeason
            .compactMap {$0}
            .flatMap { TraktvService.episodes(for: self.show, season: $0) }
            .assign(to: \.episodes, on: self)
            .dispose(bag)

        $episodes.sink { [weak self] epis in
            guard let self = self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<Section, Episode>()
            snapshot.appendSections([.main])
            snapshot.appendItems(epis)
            self.dataSource.apply(snapshot)
        }.dispose(bag)
    }

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.delegate = self
        view.register(SeasonTableViewCell.self, forCellReuseIdentifier: "myCell")
        return view
    }()

    private lazy var dataSource: UITableViewDiffableDataSource<Section, Episode> = {
        return UITableViewDiffableDataSource<Section, Episode>(tableView: tableView) { (table, path, epis) -> UITableViewCell? in
            let cell = table.dequeueReusableCell(withIdentifier: "myCell", for: path)
            if let cell = cell as? SeasonTableViewCell {
                cell.textLabel?.text = "\(epis.number). \(epis.title)"
                cell.detailTextLabel?.text = epis.formattedSeasonEpisode
            }
            return cell
        }
    }()
}

extension ShowEpisodesListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let epis = episodes[indexPath.row]
        selectedEpisode = epis
    }
}
