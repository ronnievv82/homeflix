//
//  TVHeaderView.swift
//  homeflixtvos
//
//  Created by Martin Púčik on 06/04/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import Foundation
import UIKit

final class TVHeaderView: UICollectionReusableView {
    var tvStation: TVStation? {
        didSet {
            guard let station = tvStation else {
                titleLabel.text = ""
                return
            }
            titleLabel.text = station.name
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        tvStation = nil
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        return label
    }()
}

private extension TVHeaderView {
    func setupAppearance() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(20)
        }
    }

    func setupConstraints() {

    }
}
