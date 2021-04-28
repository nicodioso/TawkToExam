//
//  UserNoteCoreDataManager.swift
//  TawkToExam
//
//  Created by Nico Adrianne Dioso on 4/21/21.
//

import CoreData
import UIKit

class UserNoteCoreDataManager: BaseCoreDataManager<UserNoteCoreDataCoder> {
    init(context: NSManagedObjectContext? = nil) {
        super.init(entityName: "UserNoteCoreData", context: context)
    }
    
//    override func decode(_ object: NSManagedObject) throws -> UserNote {
//        guard let username = object.value(forKeyPath: "username") as? String,
//              let noteBody = object.value(forKeyPath: "noteBody") as? String
//        else {
//            throw CoreDataManagerError.parseFailure
//        }
//        return UserNote(username: username, noteBody: noteBody)
//    }
//
//    override func encode(_ data: UserNote) -> [String : Any] {
//        return [
//            "username": data.username,
//            "noteBody": data.noteBody
//        ]
//    }

    var storage: [String: String] = [:]

    func getAllDataAndStore(completion: (([String: String])->())? = nil) {
        retrieveAll { result in
            switch result {
            case .failure(_):
                print("Error || Retrieving for UserNote failed")
            case .success(let array):
                array.forEach{ storage[$0.username] = $0.noteBody }
                completion?(storage)
            }
        }
    }
}

//struct UserNoteCoreDataManager: CoreDataManager {
//    static var managedContext: NSManagedObjectContext  {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            fatalError("app delegate not found")
//        }
//        return appDelegate.persistentContainer.viewContext
//    }
//
//    typealias DataModel = UserNote
//    static var entityName: String { "UserNoteCoreData" }
//
//    static func decode(_ object: NSManagedObject) throws -> UserNote {
//        guard let username = object.value(forKeyPath: "username") as? String,
//              let noteBody = object.value(forKeyPath: "noteBody") as? String
//        else {
//            throw CoreDataManagerError.parseFailure
//        }
//        return UserNote(username: username, noteBody: noteBody)
//    }
//
//    static func encode(_ data: UserNote) -> [String : Any] {
//        return [
//            "username": data.username,
//            "noteBody": data.noteBody
//        ]
//    }
//
//    static var storage: [String: String] = [:]
//
//    static func getAllDataAndStore() {
//        retrieveAll { result in
//            switch result {
//            case .failure(_):
//                print("Error || Retrieving for \(String(describing: DataModel.self)) failed")
//            case .success(let array):
//                array.forEach{ storage[$0.username] = $0.noteBody }
//            }
//        }
//    }
//}
