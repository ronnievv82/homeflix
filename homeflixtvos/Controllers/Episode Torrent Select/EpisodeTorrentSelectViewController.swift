//
//  EpisodeTorrentSelectViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 15/01/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import UIKit
import Combine

private enum Section {
    case main
}

final class EpisodeTorrentSelectViewController: UIViewController {
    private let show: Show
    private let episode: Episode
    private let bag: CancelBag = CancelBag()
    @Published private var torrents: [Torrent] = []

    init(show: Show, episode: Episode) {
        self.show = show
        self.episode = episode
        super.init(nibName: nil, bundle: nil)

        SevenTorrentsService.torrents(show: show, episode: episode)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .assign(to: \.torrents, on: self)
            .dispose(bag)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.addSubview(blurView)
        view.addSubview(titleLabel)
        view.addSubview(tableView)

        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }

        titleLabel.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview().inset(40)
        }

        tableView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
        }

        $torrents.receive(on: DispatchQueue.main).sink { [weak self] tors in
            guard let self = self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<Section, Torrent>()
            snapshot.appendSections([.main])
            snapshot.appendItems(tors)
            self.dataSource.apply(snapshot)
        }.dispose(bag)
    }

    private lazy var blurView: UIVisualEffectView = {
        let style: UIBlurEffect.Style = .regular
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.clipsToBounds = true
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "\(show.name) \(episode.formattedSeasonEpisode)"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textAlignment = .center
        return label
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.delegate = self
        view.register(SeasonTableViewCell.self, forCellReuseIdentifier: "myCell")
        return view
    }()

    private lazy var dataSource: UITableViewDiffableDataSource<Section, Torrent> = {
        return UITableViewDiffableDataSource<Section, Torrent>(tableView: tableView) { (table, path, tor) -> UITableViewCell? in
            let cell = table.dequeueReusableCell(withIdentifier: "myCell", for: path)
            if let cell = cell as? SeasonTableViewCell {
                cell.textLabel?.text = tor.name
                cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
                cell.detailTextLabel?.text = "S: \(tor.seeds) | P: \(tor.peers)"
                cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
            }
            return cell
        }
    }()
}

extension EpisodeTorrentSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tor = torrents[indexPath.row]
        present(PlayerViewController(torrent: tor, media: show), animated: true, completion: nil)
    }
}
