//
//  SearchViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 21/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import UIKit

final class SearchViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}
