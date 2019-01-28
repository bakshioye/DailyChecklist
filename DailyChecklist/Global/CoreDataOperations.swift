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
    
    // MARK: - Class Variables
    
    //Creating singleton object
    static let shared = CoreDataOperations()
    
    // Creating private initialiser so that the user cannot access the initialiser of this class and can only use the shared instance of this class
    private init() { }
    
    // MARK: - Checklist Functions
    
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
        let itemsConvertedToString = convertListItemsToString(items: checklist.items)
        
        
        // Setting the values for various attributes
        list.setValue(checklist.name, forKey: "name")
        list.setValue(checklist.priority.rawValue, forKey: "priority")
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
        
        // FIXME: Why is there NO ENTITY used inside this function
        
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
    
    // MARK: - Reset Time Functions
    
    /**
        Returns the reset time for a checklist *if it exists*
     
        - Parameter checklistID: UUID for the checklist
     
        - Returns: Reset time in *TimeDomain* if it exists, nil otherwise
    */
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
        
        // If we have an empty array, then it signifies that there is no reset time set for that particular Checklist
        return resetTimeFetchedFromCoreData.count == 0 ? nil : convertResetTimeToTimeDomain(timeFromCoreData: resetTimeFetchedFromCoreData[0])

    }
    
    // FIXME: In case the user wants to remove the reset time from the checklist, we need to handle it here by passing nil as the first parameter
    
    /**
        Update the reset time for the checklist. Creates a new reset time for a checklist if one does not exist
     
        - Parameter time: New reset time
        - Parameter checklistID: UUID for the checklist to be updated
     
        - Returns: Status for updation of the reset time for checklist
    */
    func updateResetTime(_ time: TimeDomain, checklistID: UUID) -> DatabaseQueryResult {
        
        // Fetching the App Delegate object
        guard let appDelegate = UIApplication.shared.delegate  as? AppDelegate else {
            return .Failure
        }
        
        // Fetching the managed context object
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating the fetch request object
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntities.ResetTime.rawValue)
        
        // Fetching only a particular row from Core Data that has that checklist ID
        fetchRequest.predicate = NSPredicate(format: "checklistID == %@", checklistID as CVarArg)
        
        /// Array that stores reset times fetched from Core Data
        var resetTimesFromCoreData = [NSManagedObject]()
        
        do {
            resetTimesFromCoreData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("------------ ERROR IN FETCHING RESET TIMES FROM CORE DATA ----------- \\n \(error)")
            fatalError()
        }
        
        // Checking if there is already a reset time for the checklist and if not, we create a new reset time for the checklist
        guard !resetTimesFromCoreData.isEmpty else {
            
            // Creating the entity object which contains the table
            let entity = NSEntityDescription.entity(forEntityName: CoreDataEntities.ResetTime.rawValue, in: managedContext)!
            
            // Creating the managed object to insert the values into
            let managedObject = NSManagedObject(entity: entity, insertInto: managedContext)
            
            // Setting values for different attributes
            managedObject.setValue(checklistID, forKey: "checklistID")
            managedObject.setValue(time.minute, forKey: "minute")
            managedObject.setValue(time.hour, forKey: "hour")
            managedObject.setValue(time.day, forKey: "day")
            managedObject.setValue(time.week, forKey: "week")
            managedObject.setValue(time.month, forKey: "month")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("---------- ERROR IN CREATING NEW RESET TIME FOR CHECKLIST --------- \\n \(error)")
                fatalError()
            }
            
            // FIXME:
            /// we are creating the last reset time here for now but we need to ask the user whether they want to reset the checklist now or from the RESET TIME defined by them
            
            guard createLastResetAtTime(checklistID: checklistID) == .Success else {
                return .Failure
            }
            
            return .Success
        }
        
        /// If we reach here, we have a reset time set for the checklist and so we update the existing
        
        // Since there will only be one present in the array(because we used predicate), it will always be the first
        let resetTimeObject = resetTimesFromCoreData[0]
        
        resetTimeObject.setValue(time.minute, forKey: "minute")
        resetTimeObject.setValue(time.hour, forKey: "hour")
        resetTimeObject.setValue(time.day, forKey: "day")
        resetTimeObject.setValue(time.week, forKey: "week")
        resetTimeObject.setValue(time.month, forKey: "month")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("------------- ERROR IN UPDATING THE RESET TIME FOR THE CHECKLIST --------------- \\n \(error)")
            fatalError()
        }
        
        return .Success
        
    }
    
    /**
        This method will remove Reset time from a particuar checklist
     
        - Parameter checklistUUID: UUID for the checklist to be removed
    
        - Returns: Result for querying Core Data and whether it was success or failure
    */
    func removeResetTime(checklistUUID: UUID) -> DatabaseQueryResult {
        
        // Fetching App Delegate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return .Failure
        }
        
        // Creating a Managed Context object
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating fetch request object
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntities.ResetTime.rawValue)
        
        // Setting the predicate to filter out the particular checklist
        fetchRequest.predicate = NSPredicate(format: "checklistID == %@", checklistUUID as CVarArg)
        
        /// This will store Reset times that are fetched from Core Data
        var resetTimesFromCoreData = [NSManagedObject]()
        
        do {
            resetTimesFromCoreData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("----------- ERROR IN FETCHING RESET TIMES FROM CORE DATA \\n \(error)")
            fatalError()
        }
        
        // Deleting reset time for that particular checklist
        managedContext.delete(resetTimesFromCoreData[0])
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("--------- ERROR IN DELETING RESET TIME FROM CORE DATA ---------- \\n \(error)")
            fatalError()
        }
        
        // Removing the Last Reset at Time for the checklist as well
        guard removeLastResetAtTime(checklistID: checklistUUID) == .Success else { return .Failure }
        
        return .Success
        
    }
    
    // MARK: - Custom Reset Time Functions
    
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
    
    // MARK: - Last Reset At Time Functions
    
    /**
        Creates "Last Reset at Time" for a checklist
     
        - Parameter checklistID: ID for the checklist for which we have to add "Last Reset at Time"
     
        - Returns: Result for querying Core Data whether it was success or failure
    */
    func createLastResetAtTime(checklistID: UUID) -> DatabaseQueryResult {
        
        // Fetching the App Delegate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return .Failure }
        
        // Fetching the Managed context object
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating the entity object
        let entity = NSEntityDescription.entity(forEntityName: CoreDataEntities.LastResetAtTime.rawValue, in: managedContext)!
        
        // Creating the Managed Object to insert into Core Data via context
        let managedObject = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // Setting the values for various attributes
        managedObject.setValue(checklistID, forKey: "checklistID")
        managedObject.setValue(Date(), forKey: "date")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("--------- ERROR IN INSERTING LAST RESET AT TIME INTO CORE DATA ---------- \\n \(error)")
            fatalError()
        }
        
        return .Success
    }
    
    /**
        Fetches the last time at which the checklist was reseted at
     
        - Parameter checklistID: ID of the checklist
     
        - Returns: Last Reset at Time for the checklist in *Date*
    */
    func fetchLastResetAtTime(checklistID: UUID) -> Date? {
        
        // Fetching the App Delegate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        // Fetching the managed context object
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating the Fetch request object
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntities.LastResetAtTime.rawValue)
        fetchRequest.predicate = NSPredicate(format: "checklistID == %@", checklistID as CVarArg)
        
        var lastResetAtTimeFromCoreData = [NSManagedObject]()
        
        do {
            lastResetAtTimeFromCoreData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("------------ ERROR IN FETCHING LAST RESET AT TIME FROM CORE DATA ------------------- \\n \(error)")
            fatalError()
        }
        
        return lastResetAtTimeFromCoreData.count == 0 ? nil : (lastResetAtTimeFromCoreData[0].value(forKey: "date") as! Date)
    }
    
    /**
        Updates the "Last Reset at time" for the checklist to a new updated value
     
        - Parameter checklistID: ID of the checklist whose Last Reset at Time is to be updated
     
        - Returns: Result for querying the database whether it was success or failure
    */
    func updateLastResetAtTime(checklistID: UUID) -> DatabaseQueryResult {
        
        // Fetching the App Delelgate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return .Failure }
        
        // Fetching the Managed Context object
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating a Fetch Request Object
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntities.LastResetAtTime.rawValue)
        fetchRequest.predicate = NSPredicate(format: "checklistID == %@", checklistID as CVarArg)
        
        var lastResetAtTimeFromCoreData = [NSManagedObject]()
        
        do {
            lastResetAtTimeFromCoreData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("----------- ERROR IN FETCHING LAST RESET AT TIME FROM CORE DATA ------------- \\n \(error)")
            fatalError()
        }
        
        // Updating the LastResetAtTime for the checklist
        lastResetAtTimeFromCoreData[0].setValue(Date(), forKey: "date")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("------------- ERROR IN UPDATING LAST RESET AT TIME FOR CHECKLIST -------------- \\n \(error)")
            fatalError()
        }
        
        return .Success
        
    }
    
    /**
        Delete the "Last Reset at Time" for a checklist
     
        - Parameter checklistID: ID of the checklist whose "Last Reset at Time" is to be deleted
     
        - Returns: Result for querying the database and whether it was success or failures
    */
    func removeLastResetAtTime(checklistID: UUID) -> DatabaseQueryResult {
        
        // Fetching the app delegate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return .Failure }
        
        // Fetching the managed context object
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating a fetch request object
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntities.LastResetAtTime.rawValue)
        fetchRequest.predicate = NSPredicate(format: "checklistID == %@", checklistID as CVarArg)
        
        /// This will store the Last Reset at Time fetched from Core Data
        var lastResetAtTimeFromCoreData = [NSManagedObject]()
        
        do {
            lastResetAtTimeFromCoreData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("---------- ERROR IN FETCHING LAST RESET AT TIME FROM CORE DATA ------------ \\n \(error)")
            fatalError()
        }
        
        // Deleting the Last Reset at Time from our entity
        managedContext.delete(lastResetAtTimeFromCoreData[0])
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("------------ ERROR IN SAVING CONTEXT TO CORE DATA ----------- \\n \(error)")
            fatalError()
        }
        
        return .Success
        
    }
    
    /**
        Resets the completion status of the all the checklist items and turns them to **not completed** or *false*
     
        - Parameter checklistID: ID of the checklist whose items are to be resetted
     
        - Returns: Result for querying the Core Data and whether it was a success or failure
    */
    func resetChecklistItemsCompletionStatus(checklistID: UUID) -> DatabaseQueryResult {
        
        // Fetching the App Delegate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return .Failure }
        
        // Fetching the Managed Object context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating the fetch request object and providing a condition to narrow down the result
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntities.List.rawValue)
        fetchRequest.predicate = NSPredicate(format: "checklistID == %@", checklistID as CVarArg)
        
        var checklistFetchedFromCoreData = [NSManagedObject]()
        
        do {
            checklistFetchedFromCoreData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("---------------- ERROR IN FETCHING CHECKLIST FROM CORE DATA --------------- \\n \(error)")
            fatalError()
        }
        
        // Checking if there is some checklist with the ID that we provided
        guard checklistFetchedFromCoreData.count != 0 else {
            return .Failure
        }
        
        // Fetching the checklist that we want
        let selectedChecklist = checklistFetchedFromCoreData[0]
        
        // Resetting all the completion status of the items to not completed
        selectedChecklist.setValue(resetChecklistItemsAsString(itemsAsString: selectedChecklist.value(forKey: "items") as! String), forKey: "items")
        
        do {
            // Saving the checklist in context that we just updated
            try managedContext.save()
        } catch let error as NSError {
            print("--------- ERROR IN RESETTING THE CHECKLIST ------------- \\n \(error)")
            fatalError()
        }
        
        return .Success
        
    }
    
    // MARK: - Checklist priority functions
    
    /**
        Fetches the priority for the checklist
     
        - Parameter checklistID: ID for the checklist
     
        - Returns: *String* representation of the priority of the checklist
    */
    func fetchChecklistPriority(checklistID: UUID) -> String? {
        
        // Fetching the App Delegate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        // Creating an NSManagedContext object
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating a fetch request object
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntities.List.rawValue)
        fetchRequest.predicate = NSPredicate(format: "checklistID == %@", checklistID as CVarArg)
        
        /// This array will hold the records fetched from Core Data
        var resultsFetchedFromCoreData = [NSManagedObject]()
        
        do {
            resultsFetchedFromCoreData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("------------- ERROR IN FETCHING DATA FROM CORE DATA ----------- \\n \(error)")
            fatalError()
        }
        
        return resultsFetchedFromCoreData[0].value(forKey: "priority") as? String         
    }
    
    /**
        Updates the priority for a checklist
     
        - Parameter checklistID: ID for the checklist whose priority is to be updated
        - Parameter newPriority: New priority value for the checklist
     
        - Returns: Result for querying the database
    */
    func updateChecklistPriority(for checklistID: UUID,newPriority: ChecklistPriority) -> DatabaseQueryResult {
        
        // Fetching the App Delegate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return .Failure }
        
        // Creating managed context object
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating a fetch request object
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataEntities.List.rawValue)
        fetchRequest.predicate = NSPredicate(format: "checklistID == %@", checklistID as CVarArg)
        
        var dataFetchedFromCoreData = [NSManagedObject]()
        
        do {
            dataFetchedFromCoreData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            fatalError("-------------- ERROR IN FETCHING CHECKLIST FROM CORE DATA ------------- \\n \(error)")
        }
        
        dataFetchedFromCoreData[0].setValue(newPriority.rawValue, forKey: "priority")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            fatalError("-------------- ERROR IN SAVING CONTEXT OF CORE DATA ------------- \\n \(error)")
        }
        
        return .Success
    }
    
    // MARK: - Delete all Checklist Functions
    
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
    
    /**
     Creates an array of list items for a checklist from the string provided
     
     - Parameter listItemsInString: List of items as *String*
     
     - Returns: An array of list of items as *ListItem*
     */
    fileprivate func convertStringToListItems(listItemsInString: String) -> [ListItem] {
        
        var listItemArray = [ListItem]()
        
        let arrayOfItems = listItemsInString.components(separatedBy: "\\i")
        
        for currentItem in arrayOfItems {
            
            // 0 position will have name of the item and 1 positon will have the status of that item
            let tempArray = currentItem.components(separatedBy: "\\b")
            
            listItemArray.append(ListItem(name: tempArray[0], isCompleted: Bool(tempArray[1])!))
        }
        
        return listItemArray
    }
    
    /**
     Here we convert **List of items** into a string in which items and its completion status will be seperated by some characters
     
     - Parameter items: An array of List Item of a checklist
     
     - Returns: A string made up of List Items and its completion status combined as one and seperated by some identifiers
     */
    fileprivate func convertListItemsToString(items: [ListItem]) -> String {
        
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
        It takes the string which has all the item names and it completion status and resets all the item's completion status to **Not Completed** or **false**
     
        - Parameter itemsAsString: String representation of items and their completion status combined
     
        - Returns: Updated *string* representation of the checklist items with their completion status set to **false**
    */
    fileprivate func resetChecklistItemsAsString(itemsAsString: String) -> String {
    
        let checklistItemsAsListItems = convertStringToListItems(listItemsInString: itemsAsString)
        
        let updatedChecklistListItems = checklistItemsAsListItems.map( { ListItem(name: $0.name, isCompleted: false) } )
        
        return convertListItemsToString(items: updatedChecklistListItems)
        
    }
    
}
