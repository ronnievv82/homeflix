//
//  PlayerInfoView.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 28/12/2019.
//  Copyright © 2019 MartinPucik. All rights reserved.
//

import UIKit

final class PlayerInfoView: UIView {

    init() {
        super.init(frame: .zero)
        layer.cornerRadius = 16
        clipsToBounds = true
        
        addSubview(blurView)
        addSubview(tabBar)
        addSubview(contentView)

        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tabBar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    private lazy var blurView: UIVisualEffectView = {
        let style: UIBlurEffect.Style = .regular
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.clipsToBounds = true
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurView
    }()

    private lazy var tabBar: UITabBar = {
        let bar = UITabBar()
        bar.setItems([UITabBarItem(title: "Info", image: nil, tag: 0),
                      UITabBarItem(title: "Subtitles", image: nil, tag: 1)], animated: false)
        bar.itemSpacing = 16
        bar.delegate = self
        return bar
    }()

    private lazy var contentView: UIView = UIView()

}

extension PlayerInfoView: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

    }
}
