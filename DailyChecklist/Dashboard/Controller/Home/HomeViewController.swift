//
//  HomeViewController.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 14/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {

    // MARK: - Outlet Variables
    
    @IBOutlet weak var checklistCollectionView: HomeCollectionView!
    
    // MARK: - Variables to be used
    var checklistsArray = [NSManagedObject]()
    
    // MARK: - Overriding Inbuilt functions
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Fetching all the Checklists that are there in Core Data
        guard let checklistsFetched = CoreDataOperations.shared.fetchChecklists() else {
            presentErrorAlert(title: "Oops! Something went wrong", message: "We could not fetch the checklists, Please close the app and try again")
            return
        }
        
        // Checking if the noChecklistView already exists or not
        for currentView in checklistCollectionView.subviews {
            if currentView is NoChecklistView { return }
        }
        
        // Checking if there is any checklist in Core data
        guard checklistsFetched.count > 0 else {
            // present view for no checklist here
            let frame = CGRect(x: 0, y: 0, width: checklistCollectionView.viewWidth, height: checklistCollectionView.viewHeight)
            checklistCollectionView.addSubview(NoChecklistView(frame: frame))
            return
        }
        
        checklistsArray = checklistsFetched
        checklistCollectionView.reloadData()
        
    }
    
    @IBAction func editHome(_ sender: UIButton) {
        
        if CoreDataOperations.shared.deleteAllChecklists() == .Failure {
            presentErrorAlert(title: "Deletion failed", message: "Could not delete all the checklists")
        }
        
        checklistsArray.removeAll()
        checklistCollectionView.reloadData()
        
        self.viewDidAppear(true)
        
    }
    
    @IBAction func createNewChecklist(_ sender: UIButton){
        
        let newChecklistVCObject = AppStoryboards.ChecklistBoard.instance.instantiateViewController(withIdentifier: "newChecklistVC") as! NewChecklistViewController
        
        self.navigationController?.pushViewController(newChecklistVCObject, animated: true)
        
    }
    
}

// MARK: - Collection View Data Source
extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return checklistsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HOME_CHECKLIST_CELL_ID, for: indexPath) as! HomeCVCell
        
        // Fetching the current checklist from the array as NSManagedObject
        let currentChecklist = checklistsArray[indexPath.row]
        
        // Setting the name of the checklist to the label
        cell.someTitleLable.text = currentChecklist.value(forKey: "name") as? String
        
        // Parsing the items which are in string format and fetching the count of items that are completed out of total
        let collectionOfItemsCount = fetchNumberOfCompletedItems(currentChecklist.value(forKey: "items") as! String)
        
        // Assigning the values to create that progress circle
        cell.tasksCompleted = CGFloat(collectionOfItemsCount.completed)
        cell.totalTasks = CGFloat(collectionOfItemsCount.total)
        
        // Calling it from here as if we did it from awakeFromNib(), the class variables were not yet initialised
        cell.setupChecklistProgress()
        
        return cell
        
    }
    
}

// MARK: - Collection View delegate
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Sending the user to the detailed checklist for updation or checking
        let checklistDetailVCObject = AppStoryboards.ChecklistBoard.instance.instantiateViewController(withIdentifier: "checklistVC") as! ChecklistViewController
        
        checklistDetailVCObject.selectedChecklist = checklistsArray[indexPath.row]
        
        self.navigationController?.pushViewController(checklistDetailVCObject, animated: true)
        
        
    }
    
}

// MARK: - Collection View Delegate Flow Layout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.viewWidth/2 - 10 , height: collectionView.viewHeight/3 - 10)
    }
    
}

// MARK: - Helper Functions
extension HomeViewController {
    
    /**
        Extract the number of items that have their status completed and total tasks as well
     
        - Parameter itemsAsString: Items of a checklist in the form of a string
     
        - Returns: A tuple which contains completed items and total items
    */
    fileprivate func fetchNumberOfCompletedItems(_ itemsAsString: String) -> (completed: Int, total: Int ) {
        
        /// This will contain items and their completion status with \b as seperator between them
        let arrayOfItems = itemsAsString.components(separatedBy: "\\i")
        
        /// This will create a dictionary by splitting the item and its completion status
        var dictionaryOfItemsAndItsStatus = Dictionary<String,Bool>()
        
        for currentItem in arrayOfItems {
            let combinationOfItemsAndValues = currentItem.components(separatedBy: "\\b")
            
            dictionaryOfItemsAndItsStatus[combinationOfItemsAndValues[0]] = combinationOfItemsAndValues[1] == "true"
        }
        
        let itemsWithStatusComleted = dictionaryOfItemsAndItsStatus.filter( { $1 == true } )
        
        return (itemsWithStatusComleted.count, dictionaryOfItemsAndItsStatus.count)
        
    }
    
}
