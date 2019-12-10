//
//  CoreDataManager.swift
//  CompileClock
//
//  Created by Henry Cooper on 07/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import CoreData

final class CoreDataManager {
    
    // MARK: - Properties
    private let modelName: String
    private static let shared = CoreDataManager(modelName: "CompileClock")
    static let moc = CoreDataManager.shared.managedObjectContext
    static let privateMoc = CoreDataManager.shared.privateManagedObjectContext
    
    // MARK: - Initialisation
    init(modelName: String) {
        self.modelName = modelName
        createApplicationSupportFolderIfNeeded()
    }
    
    // MARK: - Model
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError()
        }
        return model
    }()
    
    // MARK: - Persistent Coordinator
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreName = "\(modelName).sqlite"
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let peristentStoreURL = FileManager.compileClockApplicationSupportFolder.appendingPathComponent(persistentStoreName)
        let options = [ NSInferMappingModelAutomaticallyOption : true,
                        NSMigratePersistentStoresAutomaticallyOption : true]
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: peristentStoreURL, options: options)
        return persistentStoreCoordinator
    }()
    
    // MARK: - MOC
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let newMoc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        newMoc.parent = managedObjectContext
        newMoc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return newMoc
    }()
    
    static func saveOnMainThread() {
        do {
            try moc.save()
            LogUtility.updateLogWithEvent(.coreDataSaveSucceeded)
        }
        catch let error {                LogUtility.updateLogWithEvent(.coreDataSaveFailed(error.localizedDescription))
        }
    }
    
    private func createApplicationSupportFolderIfNeeded() {
        let url = FileManager.compileClockApplicationSupportFolder
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error {
            print(error)
        }
    }
    
}
