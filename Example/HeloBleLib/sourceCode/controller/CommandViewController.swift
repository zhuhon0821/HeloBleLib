//
//  CommandViewController.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/4/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SVProgressHUD
import Foundation

class CommandViewController: UIViewController {
    var commands:[String] = [
        "sync base info",
        "sync health detail info",
    ]
    lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .blue
        return label
    }()
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
        BleManager.sharedInstance.dataSyncDelegate = self
        self.view.backgroundColor = .white
        self.title = "Command"
        self.view.addSubview(self.progressLabel)
        self.view.addSubview(self.commandCollectionView)
        self.progressLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(80)
        }
        self.commandCollectionView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.bottom.equalTo(self.progressLabel.snp.top)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
    }
    func getYearMonthDay(_ date: Date) -> String {
        
        return "\(NSCalendar.current.component(.year, from: date))-\(NSCalendar.current.component(.month, from: date))-\(NSCalendar.current.component(.day, from: date))"
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

            BleManager.sharedInstance.syncHealthData {date,type,progress,allCompleted  in
                
            }
            
            break
        default:
            break
        }
     
    }
}
extension CommandViewController: BleDataSyncDelegate {
    func onSyncingWithHealthData(_ date: Date, _ type: HealthDataType, _ progress: Float, _ allCompleted: Bool) {
        progressLabel.text = "sync progress:\(Int(progress*100))%\ndata type:\(type)\ndate:\(getYearMonthDay(date))\nsync completed:\(allCompleted)"
    }
}
