//
//  GRDBManager.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/4/18.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import GRDB


struct IndexModel: Codable, FetchableRecord, PersistableRecord {
    
    var uid: String
    var data_from: String
    var date: Date
    var seq_start: Int
    var seq_end: Int
    var indexType:Int
    
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
                try db.create(table: "index_table",ifNotExists: true) { t in
                    t.primaryKey(["uid","date","data_from"], onConflict: .replace)
                    t.column("uid", .integer).notNull()
                    t.column("data_from", .text).notNull()
                    t.column("date", .date).notNull()
                    t.column("seq_start", .integer).notNull()
                    t.column("seq_end", .integer).notNull()
                    t.column("indexType", .integer).notNull()
                    
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
                print("The path already exists and is a directory.")
            } else {
                print("The path already exists and is a file.")
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
            
        }
    }
    func selectIndexModels(type:Int,uid:String,data_from:String,date:Date)->[IndexModel] {
        var models: [IndexModel]?
        do {
            models = try dbQueue.read { db in
                try IndexModel.fetchAll(db).filter { indexModel in
                    indexModel.uid == uid && indexModel.indexType == type && indexModel.data_from == data_from && indexModel.date == date
                }
            }
            
        } catch {
            
        }
        return models ?? []
    }
    func deleteIndexModel(model:IndexModel) {
        do {
           _ = try dbQueue.write { db in
               IndexModel.delete(model)
//               Player.deleteAll(db)
               
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

