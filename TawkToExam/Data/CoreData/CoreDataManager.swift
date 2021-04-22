//
//  CoreDataManager.swift
//  TawkToExam
//
//  Created by Nico Adrianne Dioso on 4/21/21.
//

import UIKit
import CoreData

protocol CoreDataManager {
    associatedtype DataModel
    static var entityName: String { get }
    
    static func decode(_ object: NSManagedObject) throws -> DataModel
    static func encode(_ data: DataModel) -> [String:Any]
}

extension CoreDataManager {
    static var appDelegate: AppDelegate {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("app delegate not found")
        }
        return appDelegate
    }
    
    static func retrieveAll(completion: (Result<[DataModel], CoreDataManagerError>)->()) {
        let managedContext = self.appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            let rawData = try managedContext.fetch(fetchRequest)
            var outputData = [DataModel]()
            rawData.forEach { object in
                guard let decoded = try? decode(object)
                else {
                    print("Error || could not decode object")
                    return
                }
                outputData.append(decoded)
            }
            completion(.success(outputData))
        } catch let error as NSError {
            print("Error || Could not fetch. \(error), \(error.userInfo)")
            completion(.failure(.parseFailure))
        }
    }
    
    static func save(_ data: DataModel, completion: ((Bool)->())? = nil) {
        let newRowData = self.encode(data)
        
        let managedContext = self.appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: self.entityName,
                                                in: managedContext)!
        let userRowDataEntity = NSManagedObject(entity: entity,
                                                insertInto: managedContext)
        
        for (key, value) in newRowData {
            userRowDataEntity.setValue(value, forKey: key)
        }
        
        do {
            try managedContext.save()
            completion?(true)
        } catch let error as NSError {
            print("Error || Could not save. \(error), \(error.userInfo)")
            completion?(false)
        }
    }
    
    static func clearAll(completion: ((Bool)->())? = nil) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: self.entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let managedContext = self.appDelegate.persistentContainer.viewContext
        
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
            completion?(true)
        } catch {
            print("Error || Could not clear User row data saved")
            completion?(false)
            // TODO: handle the error
        }
    }
}

enum CoreDataManagerError: Error {
    case parseFailure
}

