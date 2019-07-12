//
//  CoreDataManager.swift
//  BuildBuddy
//
//  Created by Henry Cooper on 07/07/2019.
//  Copyright © 2019 Henry Cooper. All rights reserved.
//

import CoreData

final class CoreDataManager {
    
    // MARK: - Properties
    private let modelName: String
    private static let shared = CoreDataManager(modelName: "BuildBuddy")
    static let moc = CoreDataManager.shared.managedObjectContext
    
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
        let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        guard let buildBuddyURL = applicationSupport?.appendingPathComponent("BuildBuddy") else { fatalError() }
        let peristentStoreURL = buildBuddyURL.appendingPathComponent(persistentStoreName)
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: peristentStoreURL, options: nil)
        return persistentStoreCoordinator
    }()
    
    // MARK: - MOC
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    
    static func save() {
        guard moc.hasChanges else {
            return
        }
        do {
            try moc.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func createApplicationSupportFolderIfNeeded() {
        let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        guard let url = applicationSupport?.appendingPathComponent("BuildBuddy") else { fatalError() }
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error {
            print(error)
        }
    }
    
}
