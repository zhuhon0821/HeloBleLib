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

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

class HomeViewController: UIViewController, BleManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
   
    var devices = [CBPeripheral]()
    var connectedDevice:CBPeripheral?
    
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
        var userConf = UserConf()
        /*
        userConf.age = 18
        userConf.gender = true
        userConf.height = 180
        userConf.calibRun = 100
        userConf.calibWalk = 100
        ProbuffManager.sharedInstance.setPersonalInfo(userConf: userConf) */
        let button = UIBarButtonItem(title: "scan", style: .plain, target: self, action: #selector(rightButtonTapped))
        self.navigationItem.rightBarButtonItem = button
        let button2 = UIBarButtonItem(title: "disconnect", style: .plain, target: self, action: #selector(leftButtonTapped))
        self.navigationItem.leftBarButtonItem = button2
        
        self.title = "Home"
        self.view.backgroundColor = UIColor.white
        BleManager.sharedInstance.delegate = self
        self.view.addSubview(self.homeCollectionView)
        self.homeCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @objc func rightButtonTapped() {
        // 按钮点击事件处理
        print("scan按钮被点击")
        if connectedDevice != nil {
            return
        }
        BleManager.sharedInstance.startScanBleDevice(uuids: nil)
    }
    @objc func leftButtonTapped() {
        // 按钮点击事件处理
        print("disconnect按钮被点击")
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
//                if name.hasPrefix("BIOSENSE-") {
                    print(peripheral)
                    self.devices.append(peripheral)
                    self.homeCollectionView.reloadData()
//                }
            }
        }
    }
    
    func didConnectedDeviceSuccess(peripheral: CBPeripheral) {
        print("didConnectedDeviceSuccess")
        connectedDevice = peripheral
        self.homeCollectionView.reloadData()
        
    }
    
    func didConnectedDeviceFailed(peripheral: CBPeripheral) {
        print("didConnectedDeviceFailed")
    }
    
    func didDisconnectedDevice(peripheral: CBPeripheral) {
        print("didDisconnectedDevice")
        connectedDevice = nil
        self.homeCollectionView.reloadData()
    }
    
}

extension HomeViewController {
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
        let p = self.devices[indexPath.item]
        BleManager.sharedInstance.connectBleDevice(peripheral: p)
        BleManager.sharedInstance.stopScanBleDevice()
    }
}
