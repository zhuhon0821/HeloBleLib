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
struct HealthDataModel: Equatable,Codable,TableRecord, FetchableRecord, PersistableRecord {
    static let tableName = "healthDataModel"
    
    var data_from: String
    var date: Date
    var seq: UInt32
    var is_processed:Bool
    var step: UInt32
    var calorie: Float
    var distance: Float
    var sport_type: Int
    var state_type: Int
    var pre_minute: Int
    var cmd: String
    init(data_from: String, date: Date, seq: UInt32, is_processed: Bool, step: UInt32, calorie: Float, distance: Float, sport_type: Int, state_type: Int, pre_minute: Int, cmd: String) {
        self.data_from = data_from
        self.date = date
        self.seq = seq
        self.is_processed = is_processed
        self.step = step
        self.calorie = calorie
        self.distance = distance
        self.sport_type = sport_type
        self.state_type = state_type
        self.pre_minute = pre_minute
        self.cmd = cmd
    }
   
}

struct HeartRateModel:Equatable,Codable,TableRecord, FetchableRecord, PersistableRecord {
    var data_from: String
    var date: Date
    var maxBpm: Int
    var minBpm: Int
    var avgBpm: Int
    init(data_from: String, date: Date, maxBpm: Int, minBpm: Int, avgBpm: Int) {
        self.data_from = data_from
        self.date = date
        self.maxBpm = maxBpm
        self.minBpm = minBpm
        self.avgBpm = avgBpm
    }
}
struct FatigueModel:Equatable,Codable,TableRecord, FetchableRecord, PersistableRecord {
    var data_from: String
    var date: Date
    var sdnn: Float
    var rmssd: Float
    var pnn50: Float
    var mean: Float
    var fatigue: Float
    init(data_from: String, date: Date, sdnn: Float, rmssd: Float, pnn50: Float, mean: Float, fatigue: Float) {
        self.data_from = data_from
        self.date = date
        self.sdnn = sdnn
        self.rmssd = rmssd
        self.pnn50 = pnn50
        self.mean = mean
        self.fatigue = fatigue
    }
}
struct BloodPresureModel:Equatable,Codable,TableRecord, FetchableRecord, PersistableRecord {
    var data_from: String
    var date: Date
    var sbp:Int
    var dbp:Int
    var bpm:Int
    init(data_from: String, date: Date, sbp: Int, dbp: Int, bpm: Int) {
        self.data_from = data_from
        self.date = date
        self.sbp = sbp
        self.dbp = dbp
        self.bpm = bpm
    }
}
struct MoodModel:Equatable,Codable,TableRecord, FetchableRecord, PersistableRecord {
    var data_from: String
    var date: Date
    var moodLevel:Int
    init(data_from: String, date: Date, moodLevel: Int) {
        self.data_from = data_from
        self.date = date
        self.moodLevel = moodLevel
    }
}
struct Spo2Model:Equatable,Codable,TableRecord, FetchableRecord, PersistableRecord {
    var data_from: String
    var date: Date
    var maxOxy:Int
    var avgOxy:Int
    var minOxy:Int
    init(data_from: String, date: Date, maxOxy: Int, avgOxy: Int, minOxy: Int) {
        self.data_from = data_from
        self.date = date
        self.maxOxy = maxOxy
        self.avgOxy = avgOxy
        self.minOxy = minOxy
    }
}
struct TemperatureModel:Equatable,Codable,TableRecord, FetchableRecord, PersistableRecord {
    var data_from: String
    var date: Date
    var huanjing_temp:Int
    var tibiao_temp:Int
    var yuce_temp:Int
    var shice_temp:Int
    var temp_ype:Int
    init(data_from: String, date: Date, huanjing_temp: Int, tibiao_temp: Int, yuce_temp: Int, shice_temp: Int, temp_ype: Int) {
        self.data_from = data_from
        self.date = date
        self.huanjing_temp = huanjing_temp
        self.tibiao_temp = tibiao_temp
        self.yuce_temp = yuce_temp
        self.shice_temp = shice_temp
        self.temp_ype = temp_ype
    }
}
struct IaqModel:Equatable,Codable,TableRecord, FetchableRecord, PersistableRecord {
    var data_from: String
    var date: Date
    var iaq: Float
    var tvoc: Float
    var etoh: Float
    var eco2: Float
    var humidity: Float
    var temperature: Float
    var autoMeasure: Bool
    init(data_from: String, date: Date, iaq: Float, tvoc: Float, etoh: Float, eco2: Float, humidity: Float, temperature: Float, autoMeasure: Bool) {
        self.data_from = data_from
        self.date = date
        self.iaq = iaq
        self.tvoc = tvoc
        self.etoh = etoh
        self.eco2 = eco2
        self.humidity = humidity
        self.temperature = temperature
        self.autoMeasure = autoMeasure
    }
}
struct OaqModel:Equatable,Codable,TableRecord, FetchableRecord, PersistableRecord {
    var data_from: String
    var date: Date
    var o3: Float
    var fastAqi: Float
    var epaAqi: Float
    var humidity: Float
    var temperature: Float
    var autoMeasure: Bool
    init(data_from: String, date: Date, o3: Float, fastAqi: Float, epaAqi: Float, humidity: Float, temperature: Float, autoMeasure: Bool) {
        self.data_from = data_from
        self.date = date
        self.o3 = o3
        self.fastAqi = fastAqi
        self.epaAqi = epaAqi
        self.humidity = humidity
        self.temperature = temperature
        self.autoMeasure = autoMeasure
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
                try db.create(table: HealthDataModel.tableName,ifNotExists: true) { t in
                    t.primaryKey(["date","data_from","seq"], onConflict: .replace)
                    t.column("data_from", .text).notNull()
                    t.column("date", .date).notNull()
                    t.column("seq", .integer).notNull()
                    t.column("is_processed", .boolean).notNull()
                    t.column("step", .integer).notNull()
                    t.column("calorie", .double).notNull()
                    t.column("distance", .double).notNull()
                    t.column("sport_type", .integer).notNull()
                    t.column("state_type", .integer).notNull()
                    t.column("pre_minute", .integer).notNull()
                }
                /**
                 var data_from: String
                 var date: Date
                 var seq: UInt32
                 var is_processed:Bool
                 var step: UInt32
                 var calorie: Float
                 var distance: Float
                 var sport_type: Int
                 var state_type: Int
                 var pre_minute: Int
                 */
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
    //MARK: index table
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
    func deleteIndexModel(indexModel:IndexModel) {
        do {
           _ = try dbQueue.write { db in
               try indexModel.delete(db)
            }

        } catch {
            
        }
    }
    func updateIndexModel(indexModel:IndexModel) {
        do {
           _ = try dbQueue.write { db in
                 try indexModel.update(db)
            }

        } catch {
            
        }
    }
}

extension GRDBManager {
    //MARK: health data
    func insertHealthDataModels(indexModels:[HealthDataModel]) {
        do {
            try dbQueue.write { db in
                for healthDataModel in indexModels {
                    try healthDataModel.insert(db)
                }
            }

        } catch {
            print(error.localizedDescription)
        }
    }
    func selectHealthDataModels(data_from:String,isProcessed:Bool)->[HealthDataModel] {
        var models: [HealthDataModel]?
        do {
            models = try dbQueue.read { db in
                try HealthDataModel.fetchAll(db).filter { healthDataModel in
                    healthDataModel.data_from == data_from && healthDataModel.is_processed == isProcessed
                }.sorted { healthDataModel1, healthDataModel2 in
                    healthDataModel1.date < healthDataModel2.date
                }
            }
            
        } catch {
            
        }
        return models ?? []
    }
    
    func deleteHealthDataModel(healthDataModel:HealthDataModel) {
        do {
           _ = try dbQueue.write { db in
               try healthDataModel.delete(db)
            }

        } catch {
            
        }
    }
    func updateHealthDataModel(healthDataModel:HealthDataModel) {
        do {
           _ = try dbQueue.write { db in
                 try healthDataModel.update(db)
            }

        } catch {
            
        }
    }
}
