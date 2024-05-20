//
//  HomeViewController.swift
//  HeloBleDemo
//
//  Created by AppleDev_9527 on 2024/4/9.
//

import UIKit
import HeloBleLib
import GRDB
import CoreBluetooth
@_exported import SnapKit
import SVProgressHUD

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

class HomeViewController: UIViewController, BleManagerDelegate {
   
    var devices = [CBPeripheral]()
    var connectedDevice:CBPeripheral?
    lazy var commandButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("send command", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.addTarget(self, action: #selector(sendCommand), for: .touchUpInside)
        return btn
    }()
    lazy var homeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth-20, height: 50)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        homeCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), collectionViewLayout: layout)
        homeCollectionView.dataSource = self
        homeCollectionView.delegate = self
        homeCollectionView.register(BleDeviceCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: NSStringFromClass(BleDeviceCollectionViewCell.classForCoder()))
        
        return homeCollectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
//        let sleep = IVSleep()
//        let af = AfAiLib()
//        let re = AfAiLib.afAiResult([1])
//        let le = AfAiLib.afAiConfdenceLevel([1])
//        let healthIndexs = GRDBManager.sharedInstance.selectIndexModels(type:HealthDataType.healthDataEncrypt.rawValue, data_from: BleManager.sharedInstance.getDeviceName()!, isSynced: true)
//        var dateStrs = [String]()
//        var dates = [Date]()
//        for healthIndex in healthIndexs {
//            let date = healthIndex.date.getYearMonthDay()
//            if !dateStrs.contains(date) {
//                dateStrs.append(date)
//                dates.append(healthIndex.date.startOfDay())
//            }
//        }
//        var healthArr = [[HealthDataModel]]()
//        for date in dates {
//            let healths = GRDBManager.sharedInstance.selectHealthDataModels(data_from: BleManager.sharedInstance.getDeviceName()!, isProcessed: false,date: date)
//            healthArr.append(healths)
//        }
        
        let button = UIBarButtonItem(title: "scan", style: .plain, target: self, action: #selector(rightButtonTapped))
        self.navigationItem.rightBarButtonItem = button
        let button2 = UIBarButtonItem(title: "disconnect", style: .plain, target: self, action: #selector(leftButtonTapped))
        self.navigationItem.leftBarButtonItem = button2
        
        self.title = "Home"
        self.view.backgroundColor = UIColor.white
        BleManager.sharedInstance.delegate = self
        
        self.view.addSubview(self.homeCollectionView)
        self.view.addSubview(self.commandButton)
        self.homeCollectionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.commandButton.snp.top)
        }
        self.commandButton.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    @objc func sendCommand() {
        if connectedDevice == nil {
            SVProgressHUD.showError(withStatus: "none of connected")
            return
        }
        let vc = CommandViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func rightButtonTapped() {
        
        if connectedDevice != nil {
            return
        }
        BaseDataManager.clearDeviceName()
        BleManager.sharedInstance.startScanBleDevice(uuids: nil)
    }
    @objc func leftButtonTapped() {
        
        if let p = connectedDevice {
            BleManager.sharedInstance.cancelConnectBleDevice(peripheral: p)
        }
        
    }
    
}

extension HomeViewController {
    func didReceiveDeviceState(state: CBManagerState) {
        print(state)
        if state == .poweredOn {
            BleManager.sharedInstance.startScanBleDevice(uuids: nil)
        }
    }
    
    func didDiscoverDevice(peripheral: CBPeripheral) {
        if !self.devices.contains(peripheral) && peripheral.name?.count ?? 0 > 0 {
            if let name = peripheral.name {
                if name.hasPrefix("BIOSENSE-") {
                    print(peripheral)
                    self.devices.append(peripheral)
                    self.homeCollectionView.reloadData()
                }
            }
        }
    }
    
    func didConnectedDeviceSuccess(peripheral: CBPeripheral) {
        print("didConnectedDeviceSuccess")
        if self.devices.count == 0 {
            self.devices.append(peripheral)
        }
        connectedDevice = peripheral
        self.homeCollectionView.reloadData()
        SVProgressHUD.showSuccess(withStatus: "Connect Success")
        
        BaseDataManager.saveDeviceName(name: peripheral.name ?? "")
        
    }
    
    func didConnectedDeviceFailed(peripheral: CBPeripheral) {
        print("didConnectedDeviceFailed")
        SVProgressHUD.showError(withStatus: "Connect Failed")
    }
    
    func didDisconnectedDevice(peripheral: CBPeripheral) {
        print("didDisconnectedDevice")
        connectedDevice = nil
        self.homeCollectionView.reloadData()
        SVProgressHUD.showError(withStatus: "disconnected")
    }
    
}

extension HomeViewController:UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(BleDeviceCollectionViewCell.classForCoder()), for: indexPath) as! BleDeviceCollectionViewCell
        let p = self.devices[indexPath.item]
        cell.title = p.name
        cell.isConnected = p.state == .connected
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if connectedDevice != nil {
            return
        }
        SVProgressHUD.show()
        let p = self.devices[indexPath.item]
        BleManager.sharedInstance.connectBleDevice(peripheral: p)
        BleManager.sharedInstance.stopScanBleDevice()
    }
}
