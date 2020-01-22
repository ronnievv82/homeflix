//
//  SettingsViewController.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 22/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 3)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}
