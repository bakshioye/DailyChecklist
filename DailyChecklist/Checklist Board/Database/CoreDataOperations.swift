//
//  CoreDataOperations.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 03/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataOperations {
    
    //Creating singleton object
    static let shared = CoreDataOperations()
    
    // Creating private initialiser so that the user cannot access the initialiser of this class and can only use the shared instance of this class
    private init() { }
    
    func createNewChecklist(checklist:Checklist) -> Bool {
        
        // Fething the App Delegate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false // return failure
        }
        
        // Fetching the Managed Context object from App Delegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating the entity object for List entity
        let entity = NSEntityDescription.entity(forEntityName: "List", in: managedContext)!
        
        // Creating Managed Object for List
        let list = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // Converting Dictionary to String to store in Core Data
        let itemsConvertedToString = convertItemsToString(items: checklist.items)
        
        
        // Setting the values for various attributes
        list.setValue(checklist.name, forKey: "name")
        list.setValue(itemsConvertedToString, forKey: "items")
        list.setValue(checklist.creationDate, forKey: "creationDate")
        list.setValue(checklist.resetTime, forKey: "resetTime") // Can be nil
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print(" -------- Error in saving data to Core Data : \(error)")
            fatalError()
            //return false from here to signify that there was some error
        }
        
        //successfully saved data to Core Data
        return true
        
    }
    
    func fetchChecklists() -> [NSManagedObject]? {
        
        // Fething the App Delegate object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        // Fetching the Managed Context object from App Delegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Creating a fetch request object
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "List")
        
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
    
}

// MARK: - Supplementary functions
extension CoreDataOperations {
    
    fileprivate func convertItemsToString(items: [ListItem]) -> String {
        
        /**
            \\(Double back slash is used to avoid escape characters)
            \i -> seperator between items
            \b -> seperator between item name and it's boolean value
        **/
        
        var arrayOfItems = Array<String>()
        
        // TODO: - I WAS HERE AND WAS CHANGING THE FATE OF THE UNIVERSE :)
        
        for currentItem in items {
            arrayOfItems.append("\(currentItem.name)\\b\(currentItem.isCompleted)")
        }
        
        return arrayOfItems.joined(separator: "\\i")
        
    }
    
}
