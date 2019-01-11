//
//  CoreDataOperations.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 03/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import CoreData
import UIKit

class CoreDataOperations {
    
    //Creating singleton object
    static let shared = CoreDataOperations()
    
    // Creating private initialiser so that the user cannot access the initialiser of this class and can only use the shared instance of this class
    private init() { }
    
    func createNewChecklist(checklist:Checklist) -> DatabaseQueryResult {
        
        // Fething the App Delegate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return .Failure // return failure
        }
        
        // Fetching the Managed Context object from App Delegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating the entity object for List entity
        let entity = NSEntityDescription.entity(forEntityName: CoreDataEntities.List.rawValue, in: managedContext)!
        
        // Creating Managed Object for List
        let list = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // Converting Dictionary to String to store in Core Data
        let itemsConvertedToString = convertItemsToString(items: checklist.items)
        
        
        // Setting the values for various attributes
        list.setValue(checklist.name, forKey: "name")
        list.setValue(itemsConvertedToString, forKey: "items")
        list.setValue(checklist.creationDate, forKey: "creationDate")
        list.setValue(checklist.checklistID, forKey: "checklistID")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print(" -------- Error in saving data to Core Data : \(error)")
            fatalError()
            //return false from here to signify that there was some error
        }
        
        //successfully saved data to Core Data
        return .Success
        
    }
    
    func fetchChecklists() -> [NSManagedObject]? {
        
        // Fething the App Delegate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        // Fetching the Managed Context object from App Delegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating a fetch request object
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntities.List.rawValue)
        
        // Creating an array of managed object to fetch from core data and return it
        var checklistsAsManagedObjectsFetched = [NSManagedObject]()
        
        do {
            checklistsAsManagedObjectsFetched = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("------- Error in fetching checklist from Core Data : \(error)")
            fatalError()
            //return nil in case of failure
        }
        
        return checklistsAsManagedObjectsFetched
        
    }
    
    func updateChecklist(oldChecklist: NSManagedObject, newChecklist: Checklist) -> DatabaseQueryResult {
        
        // FIXME: - Why is there NO ENTITY used inside this function
        
        // Fetching the App Delegate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return .Failure }
        
        // Fetching the Managed Context object
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Removing the existing/old checklist
        managedContext.delete(oldChecklist)
        
        // Saving the context
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("------- Error occured while deleting the checklist: \(error)")
            fatalError()
            //return false
        }
        
        // Adding the updated checklist
        if createNewChecklist(checklist: newChecklist) == .Success {
            return .Success
        }
        
        return .Failure
        
    }
    
    func fetchResetTime(checklistID: UUID) -> TimeDomain? {
        
        // Fetching the App Delegate Object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        // Fetching the managed context Object
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating a fetch request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntities.ResetTime.rawValue)

        // Setting the predicate for the request for fetching only the row which has the UUID
        fetchRequest.predicate = NSPredicate(format: "checklistID == %@", checklistID as CVarArg)
        
        var resetTimeFetchedFromCoreData = [NSManagedObject]()
        
        do {
            resetTimeFetchedFromCoreData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("---------- ERROR IN FETCHING RESET TIME FROM CORE DATA ------------ : \(error)")
            fatalError()
        }
        
        //        print(resetTimeFetchedFromCoreData)
        
        // If we have an empty array, then it signifies that there is no reset time set for that particular Checklist
        return resetTimeFetchedFromCoreData.count == 0 ? nil : convertResetTimeToTimeDomain(timeFromCoreData: resetTimeFetchedFromCoreData[0])

    }
    
    
    func saveCustomResetTime(_ customTime: TimeDomain) -> DatabaseQueryResult {
        
        // Fetching the App Delegate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return .Failure }
        
        // Fetching the managed context object
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Fetching the entity named "CustomResetTime"
        let entity = NSEntityDescription.entity(forEntityName: CoreDataEntities.CustomResetTime.rawValue, in: managedContext)!
        
        // Creating a NSManagedObject for inserting into Core Data
        let customResetTime = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // Adding the values to the NSManagedObject
        customResetTime.setValue(customTime.minute, forKey: "minute")
        customResetTime.setValue(customTime.hour, forKey: "hour")
        customResetTime.setValue(customTime.day, forKey: "day")
        customResetTime.setValue(customTime.week, forKey: "week")
        customResetTime.setValue(customTime.month, forKey: "month")
        
        // Saving the context to save the time inside Core Data
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("------------- Error in SAVING CUSTOM RESET TIME : \(error)")
            fatalError()
            /// Return .Failure to indicate failure
        }
        
        return .Success
        
    }
    
    func fetchSavedCustomResetTime() -> [TimeDomain] {
        
        var customResetTimes = [TimeDomain]()
        
        // Fetching the App Delegate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        
        // Fetching the managed context object
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntities.CustomResetTime.rawValue)
        
        // For temporarily saving the data coming from Core Data
        var customResetTimeAsManagedObjects = [NSManagedObject]()
        
        do {
            customResetTimeAsManagedObjects = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("----------- Error in fetching CUSTOM RESET TIME : \(error)")
            fatalError()
        }
        
        for currentManagedObject in customResetTimeAsManagedObjects {
            
            customResetTimes.append((currentManagedObject.value(forKey: "minute") as! Int,
                                     currentManagedObject.value(forKey: "hour") as! Int,
                                     currentManagedObject.value(forKey: "day") as! Int,
                                     currentManagedObject.value(forKey: "week") as! Int,
                                     currentManagedObject.value(forKey: "month") as! Int))
            
        }
        
        return customResetTimes
        
    }
    
    /// For testing purpose only
    func deleteAllChecklists() -> DatabaseQueryResult {
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return .Failure }
        
        // Grabbing the NSManagedObject context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating a fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataEntities.List.rawValue)
        
        // Performing batch deletion request
        let batchDeletion = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        
        do {
            try managedContext.execute(batchDeletion)
        } catch let error as NSError {
            print("------ Error in performing batch deletion: \(error)")
            fatalError()
        }
        
        return .Success
    }
    
}

// MARK: - Supplementary functions
extension CoreDataOperations {
    
    /**
        Here we convert **List of items** into a string in which items and its completion status will be seperated by some characters
     
        - Parameter items: An array of List Item of a checklist
     
        - Returns: A string made up of List Items and its completion status combined as one and seperated by some identifiers
    */
    fileprivate func convertItemsToString(items: [ListItem]) -> String {
        
        /**
            \\(Double back slash is used to avoid escape characters)
            \i -> seperator between items
            \b -> seperator between item name and it's boolean value
        **/
        
        var arrayOfItems = Array<String>()
        
        for currentItem in items {
            arrayOfItems.append("\(currentItem.name)\\b\(currentItem.isCompleted)")
        }
        
        return arrayOfItems.joined(separator: "\\i")
        
    }
    
    /**
        Here we convert the **Reset time** fetched from the Core Data which is in form of *NSManagedObject* into a **TimeDomain** type value
     
        - Parameter resetTime: Complete NSManaged object fetched from Core Data
     
        - Returns: A *TimeDomain* object which is the converted form of resetTime fetched from Core Data
    */
    fileprivate func convertResetTimeToTimeDomain(timeFromCoreData resetTime: NSManagedObject) -> TimeDomain {
        
        return (resetTime.value(forKey: "minute") as! Int,
                resetTime.value(forKey: "hour") as! Int,
                resetTime.value(forKey: "day") as! Int,
                resetTime.value(forKey: "week") as! Int,
                resetTime.value(forKey: "month") as! Int)
        
    }
    
}
