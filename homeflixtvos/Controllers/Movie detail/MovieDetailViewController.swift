//
//  MovieDetailViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 13/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import TVUIKit

final class MovieDetailViewController: UIViewController {

    let viewModel: MovieDetailViewModel

    private let bag = CancelBag()
    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
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
        label.text = viewModel.movie.name
        return label
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.register(TorrentTableViewCell.self, forCellReuseIdentifier: "cell")
        return view
    }()
}

extension MovieDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.torrents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row < viewModel.torrents.count {
            let tor = viewModel.torrents[indexPath.row]
            cell.textLabel?.text = tor.name
            cell.detailTextLabel?.text = "\(tor.size)  S: \(tor.seeds) | L: \(tor.peers)"
            cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Torrents"
    }
}

extension MovieDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tor = viewModel.torrents[indexPath.row]
        present(PlayerViewController(torrent: tor, media: viewModel.movie), animated: true, completion: nil)
    }
}

private extension MovieDetailViewController {
    func setupAppearance() {
        view.addSubview(backgroundImageView)
        view.addSubview(blurView)
        view.addSubview(titleLabel)
        view.addSubview(tableView)

        backgroundImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        titleLabel.snp.makeConstraints { $0.leading.trailing.top.equalToSuperview().inset(80) }

        tableView.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.width.equalToSuperview().multipliedBy(0.5).inset(80)
            make.bottom.equalToSuperview().inset(40)
        }

        if let tmdb = viewModel.movie.tmdbID {
            TMDBService.getBackdropFor(mediaType: .movie, tmdb: tmdb)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] url in
                    self?.backgroundImageView.kf.setImage(with: url, options: [.backgroundDecode])
            }.dispose(bag)
        }

        viewModel.$torrents
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }.dispose(bag)
    }
}
