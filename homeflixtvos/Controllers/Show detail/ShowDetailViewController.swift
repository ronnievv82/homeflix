//
//  ShowDetailViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 10/01/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import UIKit
import Combine

final class ShowDetailViewController: UIViewController {

    private let show: Show
    private let bag: CancelBag = CancelBag()

    init(show: Show) {
        self.show = show
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAppearance()
    }

    private lazy var blurView: UIVisualEffectView = {
        let style: UIBlurEffect.Style = .regular
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.clipsToBounds = true
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurView
    }()

    private lazy var backgroundImageView: UIImageView = UIImageView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
        label.text = show.name
        return label
    }()

    private lazy var splitController: UISplitViewController = {
        let con = UISplitViewController()
        con.view.backgroundColor = .clear
        con.viewControllers = [seasonsListController, episodesListController]
        return con
    }()

    private lazy var seasonsListController: ShowSeasonsListViewController = {
        return ShowSeasonsListViewController(show: show)
    }()

    private lazy var episodesListController: ShowEpisodesListController = {
        return ShowEpisodesListController(show: show)
    }()
}

private extension ShowDetailViewController {
    func setupAppearance() {
        view.addSubview(backgroundImageView)
        view.addSubview(blurView)
        view.addSubview(titleLabel)
        view.addSubview(splitController.view)

        backgroundImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        titleLabel.snp.makeConstraints { $0.leading.trailing.top.equalToSuperview().inset(80) }

        splitController.view.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.bottom.equalToSuperview().inset(40)
        }

        TMDBService.getBackdropFor(mediaType: .tv, tmdb: show.tmdbID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                self?.backgroundImageView.kf.setImage(with: url, options: [.backgroundDecode])
            }.dispose(bag)

        seasonsListController.$selectedSeason
            .compactMap { $0 }
            .assign(to: \.selectedSeason, on: episodesListController)
            .dispose(bag)

        episodesListController.$selectedEpisode.compactMap { $0 }
            .sink(receiveValue: { ep in
                self.present(EpisodeTorrentSelectViewController(show: self.show, episode: ep),
                             animated: true, completion: nil)
            }).dispose(bag)
    }
}
