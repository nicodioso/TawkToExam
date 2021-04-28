//
//  UserRowCoreDataManager.swift
//  TawkToExam
//
//  Created by Nico Adrianne Dioso on 4/20/21.
//
import UIKit
import CoreData

class UserRowCoreDataManager: BaseCoreDataManager<UserRowCoreDataCoder> {
    init(context: NSManagedObjectContext? = nil) {
        super.init(entityName: "UserRowCoreData", context: context)
    }
    
//    override func decode(_ object: NSManagedObject) throws -> UserRowData {
//        guard let id = object.value(forKeyPath: "id") as? Int,
//              let avatarUrl = object.value(forKeyPath: "avatarUrl") as? String,
//              let login = object.value(forKeyPath: "login") as? String,
//              let siteAdmin = object.value(forKeyPath: "siteAdmin") as? Bool,
//              let type = object.value(forKeyPath: "type") as? String
//        else {
//            throw CoreDataManagerError.parseFailure
//        }
//
//        return UserRowData(id: id, avatarUrl: avatarUrl, login: login, siteAdmin: siteAdmin, type: type)
//    }
//
//    override func encode(_ data: UserRowData) -> [String : Any] {
//        return  [
//            "id" : data.id,
//            "avatarUrl" : data.avatarUrl,
//            "login" : data.login,
//            "siteAdmin" : data.siteAdmin,
//            "type" : data.type,
//        ]
//    }
}

//struct UserRowCoreDataManager: CoreDataManager {
//    static var managedContext: NSManagedObjectContext {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            fatalError("app delegate not found")
//        }
//        return appDelegate.persistentContainer.viewContext
//    }
//
//    static var storage: [UserRowData] = []
//
//    static var entityName: String {
//        return "UserRowCoreData"
//    }
//
//    static func decode(_ object: NSManagedObject) throws -> UserRowData {
//        guard let id = object.value(forKeyPath: "id") as? Int,
//              let avatarUrl = object.value(forKeyPath: "avatarUrl") as? String,
//              let login = object.value(forKeyPath: "login") as? String,
//              let siteAdmin = object.value(forKeyPath: "siteAdmin") as? Bool,
//              let type = object.value(forKeyPath: "type") as? String
//        else {
//            throw CoreDataManagerError.parseFailure
//        }
//
//        return UserRowData(id: id, avatarUrl: avatarUrl, login: login, siteAdmin: siteAdmin, type: type)
//    }
//
//    static func encode(_ data: UserRowData) -> [String : Any] {
//        return  [
//            "id" : data.id,
//            "avatarUrl" : data.avatarUrl,
//            "login" : data.login,
//            "siteAdmin" : data.siteAdmin,
//            "type" : data.type,
//        ]
//    }
//
//    typealias DataModel = UserRowData
//}
