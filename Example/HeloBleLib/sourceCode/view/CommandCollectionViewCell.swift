//
//  CommandCollectionViewCell.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/4/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class CommandCollectionViewCell: UICollectionViewCell {
    
    public var title:String? {
        didSet {
            titleLabel.text = title
        }
    }
    public var isSended:Bool? {
        didSet {
            titleLabel.textColor = !(isSended ?? false) ? .blue : .black
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        return label
    }()
    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "connected"
        label.textColor = .blue
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    lazy var seperateLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func createSubview() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.seperateLine)
//        self.addSubview(self.detailLabel)
//        self.detailLabel.snp.makeConstraints { make in
//            make.right.equalToSuperview().offset(-10)
//            make.centerY.equalToSuperview()
//        }
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        self.seperateLine.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
