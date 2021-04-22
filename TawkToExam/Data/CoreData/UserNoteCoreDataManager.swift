//
//  UserNoteCoreDataManager.swift
//  TawkToExam
//
//  Created by Nico Adrianne Dioso on 4/21/21.
//

import CoreData

struct UserNoteCoreDataManager: CoreDataManager {
    typealias DataModel = UserNote
    static var entityName: String { "UserNoteCoreData" }
    
    static func decode(_ object: NSManagedObject) throws -> UserNote {
        guard let username = object.value(forKeyPath: "username") as? String,
              let noteBody = object.value(forKeyPath: "noteBody") as? String
        else {
            throw CoreDataManagerError.parseFailure
        }
        return UserNote(username: username, noteBody: noteBody)
    }
    
    static func encode(_ data: UserNote) -> [String : Any] {
        return [
            "username": data.username,
            "noteBody": data.noteBody
        ]
    }
    
    static var storage: [String: String] = [:]
    
    static func getAllDataAndStore() {
        retrieveAll { result in
            switch result {
            case .failure(_):
                print("Error || Retrieving for \(String(describing: DataModel.self)) failed")
            case .success(let array):
                array.forEach{ storage[$0.username] = $0.noteBody }
            }
        }
    }
}
