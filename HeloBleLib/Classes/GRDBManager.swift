//
//  GRDBManager.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/4/18.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import GRDB


struct IndexModel: Equatable,Codable,TableRecord, FetchableRecord, PersistableRecord {
    static let tableName = "indexModel"
    
    var data_from: String
    var date: Date
    var seq_start: UInt32
    var seq_end: UInt32
    var indexType:Int
    var isSynced:Bool
    init(data_from: String, date: Date, seq_start: UInt32, seq_end: UInt32, indexType: Int, isSynced: Bool) {
        self.data_from = data_from
        self.date = date
        self.seq_start = seq_start
        self.seq_end = seq_end
        self.indexType = indexType
        self.isSynced = isSynced
    }
    
}



class GRDBManager: NSObject {
    public static let sharedInstance = GRDBManager()
    var dbQueue:DatabaseQueue!
    
    override init() {
        super.init()
        initDB()
        creatTables()

    }
    func initDB() {
        do {//database.sqlite
            // 1. Open a database connection
            var path = createDocumentPath(fileName: "sdk")
            path = path?.appendingPathComponent("rawDataDB.sqlite")
            dbQueue = try DatabaseQueue(path: path?.absoluteString ?? "")
                        
        } catch {
            print(error.localizedDescription)
        }
    }
    func creatTables() {
        do {
            try dbQueue.write { db in
                try db.create(table: IndexModel.tableName,ifNotExists: true) { t in
                    t.primaryKey(["date","data_from","indexType","seq_start","seq_end"], onConflict: .replace)
                    t.column("data_from", .text).notNull()
                    t.column("date", .date).notNull()
                    t.column("seq_start", .integer).notNull()
                    t.column("seq_end", .integer).notNull()
                    t.column("indexType", .integer).notNull()
                    t.column("isSynced", .boolean).notNull()
                    
                }
            }
            
        } catch {
            
        }
        
    }
    func createDocumentPath(fileName: String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentsDirectory?.appendingPathComponent(fileName)
        
        if let fileURL = fileURL, FileManager.default.fileExists(atPath: fileURL.path) {
            if FileManager.default.fileExists(atPath: fileURL.path, isDirectory: nil) {
//                print("The path already exists and is a directory.")
            } else {
//                print("The path already exists and is a file.")
            }
        } else {
            do {
                try FileManager.default.createDirectory(at: fileURL!, withIntermediateDirectories: true, attributes: nil)
                print("Directory created at path: \(fileURL?.path ?? "Unknown")")
            } catch {
                print("Error creating directory at path: \(error.localizedDescription)")
            }
        }
        
        return fileURL
    }
}

extension GRDBManager {
    
    func insertIndexModel(indexModels:[IndexModel]) {
        do {
            try dbQueue.write { db in
                for indexModel in indexModels {
                    try indexModel.insert(db)
                }
            }

        } catch {
            print(error.localizedDescription)
        }
    }
    func selectIndexModels(type:Int,data_from:String,isSynced:Bool)->[IndexModel] {
        var models: [IndexModel]?
        do {
            models = try dbQueue.read { db in
                try IndexModel.fetchAll(db).filter { indexModel in

                    indexModel.indexType == type && indexModel.data_from == data_from && indexModel.isSynced == isSynced
                }.sorted { index1, index2 in
                    index1.date < index2.date
                }
            }
            
        } catch {
            
        }
        return models ?? []
    }
    func selectIndexModelSynced(type:Int,data_from:String,startSeq:UInt32,endSeq:UInt32,date:Date,isSynced:Bool)->Bool {
        var models = [IndexModel]()
        do {
            models = try dbQueue.read { db in
                try IndexModel.fetchAll(db).filter { indexModel in

                    indexModel.indexType == type && indexModel.data_from == data_from && indexModel.seq_start == startSeq && indexModel.seq_end == endSeq && indexModel.date == date && indexModel.isSynced == isSynced
                }
            }
            
        } catch {
            
        }
        return models.count > 0
    }
    func deleteIndexModel(model:IndexModel) {
        do {
           _ = try dbQueue.write { db in
               try IndexModel.deleteAll(db)
               
            }

        } catch {
            
        }
    }
    func updateIndexModel(model:IndexModel) {
        do {
           _ = try dbQueue.write { db in
                 try model.update(db)
            }

        } catch {
            
        }
    }
}

