//
//  HomeViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 11/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import UIKit
import SwiftUI

final class HomeViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewControllers([moviesController, showsController, searchController, settingsController],
                           animated: true)
    }

    private lazy var moviesController: MoviesViewController = MoviesViewController()
    private lazy var showsController: ShowsViewController = ShowsViewController()
    private lazy var searchController: SearchViewController = SearchViewController()
    private lazy var settingsController: SettingsViewController = SettingsViewController()

}
