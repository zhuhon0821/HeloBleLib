//
//  CommandViewController.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/4/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SVProgressHUD

class CommandViewController: UIViewController {
    var commands:[String] = [
        "sync base info",
        "sync health detail info",
    ]
   
    lazy var commandCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth-20, height: 50)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
         commandCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), collectionViewLayout: layout)
         commandCollectionView.dataSource = self
         commandCollectionView.delegate = self
         commandCollectionView.register(CommandCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: NSStringFromClass(CommandCollectionViewCell.classForCoder()))
        
        return commandCollectionView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Command"
        self.view.addSubview(self.commandCollectionView)
        self.commandCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
extension CommandViewController:UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.commands.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CommandCollectionViewCell.classForCoder()), for: indexPath) as! CommandCollectionViewCell
        cell.title = self.commands[indexPath.item]
//        cell.title = p.name
//        cell.isConnected = p.state == .connected
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let command = self.commands[indexPath.item]
        SVProgressHUD.showSuccess(withStatus: command)
        switch indexPath.item {
        case 0:
            
//            let user = UserConf_C(height: 170, weight: 75, gender: true, age: 28, calibWalk: 100, calibRun: 100, grade: 1, wristCircumference: 100, historyOfHypertension: true, hash: 123456)
//            
//            ProbuffManager.sharedInstance.setUserConf(userConf: user)
            ProbuffManager.sharedInstance.read00DeviceInfomation()
            break
        case 1:
            
            break
        default:
            break
        }
     
    }
}
