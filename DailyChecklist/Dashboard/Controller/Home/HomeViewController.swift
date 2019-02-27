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
    
    /// This will keep checking if the reset time is up for a checklist
    var resetTimeChecker: Timer!
    
    // MARK: - Overriding Inbuilt functions
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Setting the large display mode for the Navigation bar title
        navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        
        // Setting the long press getsure recognizer for reordering the collection view items
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(actionForLongPressGesture(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        checklistCollectionView.addGestureRecognizer(longPressGestureRecognizer)
        
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

        
        // Here we are creating a timer which will run every minute as the shortest time that we have is 1 minute
        resetTimeChecker = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(actionForResetTimeChecker), userInfo: nil, repeats: true)
        
        // Passing the checklist array to a global variable to be used anywhere
        checklistsArray = checklistsFetched
        
        // Reloading the data
        checklistCollectionView.reloadData()
    
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        /// In case where no checklist exists in our app, the timer will never be initialised as we have decided the logic according to that and thus resetTimeChecker will be nil
        guard resetTimeChecker != nil else { return }
        
        // Invalidating the timer
        resetTimeChecker.invalidate()
        
    }
    
}

// MARK: - Actions for buttons
extension HomeViewController {
    
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
    
    // Used when we are dragging and dropping the collection view cells
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
//        /// Debugging
//        print("Source: \(sourceIndexPath.item) Destination: \(destinationIndexPath.item)")
        
        /// Here i make changes to the database regarding the index for checklists that are removed
        
        // First, i will make changes to the item's index whose location has been changed
        CoreDataOperations.shared.changeIndexForChecklist(checklistsArray[sourceIndexPath.item].value(forKey: "checklistID") as! UUID, newIndex: destinationIndexPath.item + 1) // +1 as we have index values as 1 based and .item is 0 based
        
        // We are moving the checklist below
        if sourceIndexPath.item < destinationIndexPath.item {
            
            for currentIndex in stride(from: sourceIndexPath.item + 1, through: destinationIndexPath.item, by: 1) {
                
                let currentChecklist = checklistsArray[currentIndex]
                
                CoreDataOperations.shared.changeIndexForChecklist(currentChecklist.value(forKey: "checklistID") as! UUID, newIndex: currentChecklist.value(forKey: "index") as! Int - 1)
            }
            
        }
        // We are moving the checklist above
        else {
            
            for currentIndex in stride(from: sourceIndexPath.item - 1, through: destinationIndexPath.item, by: -1) {
                
                let currentChecklist = checklistsArray[currentIndex]
                
                CoreDataOperations.shared.changeIndexForChecklist(currentChecklist.value(forKey: "checklistID") as! UUID, newIndex: currentChecklist.value(forKey: "index") as! Int + 1)
                
            }
            
        }
        
        viewDidAppear(true)
        
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
    
    fileprivate func shouldChecklistBeReseted(checklistID: UUID, resetTime: TimeDomain) -> Bool {
        
        // Checking of there exists a "Last Reset at Time" for a checklist
        guard let lastResetAtTime = CoreDataOperations.shared.fetchLastResetAtTime(checklistID: checklistID) else { return false }
        
        /// This date is computed after adding "Last Reset At Time" and "Reset Time"
        var updatedDate = lastResetAtTime
        
        // Now we are adding every date component to our updated date
        
        if resetTime.month != 0 {
            updatedDate = Calendar.current.date(byAdding: .month, value: resetTime.month, to: updatedDate, wrappingComponents: false)!
        }
        if resetTime.week != 0 {
            updatedDate = Calendar.current.date(byAdding: .weekOfMonth, value: resetTime.week, to: updatedDate, wrappingComponents: false)!
        }
        if resetTime.day != 0 {
            updatedDate = Calendar.current.date(byAdding: .day, value: resetTime.day, to: updatedDate, wrappingComponents: false)!
        }
        if resetTime.hour != 0 {
            updatedDate = Calendar.current.date(byAdding: .hour, value: resetTime.hour, to: updatedDate, wrappingComponents: false)!
        }
        if resetTime.minute != 0 {
            updatedDate = Calendar.current.date(byAdding: .minute, value: resetTime.minute, to: updatedDate, wrappingComponents: false)!
        }
        
        // We are comparing the updated date with current date and time and if it is negative , it means we have exceeded the reset time and we need to reset checklist now!
        
        return updatedDate.timeIntervalSinceNow < 0
        
    }
    
    @objc func actionForResetTimeChecker() {
 
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

        
        /// Here we will check the reset time for each checklist and update it accordingly
        
        // First we are creating an array of Checklist
        let checklists:[Checklist] = checklistsFetched.map( { Checklist(checklistID: $0.value(forKey: "checklistID") as! UUID,
                                                                        index: $0.value(forKey: "index") as! Int,
                                                                        priority: ChecklistPriority(rawValue: $0.value(forKey: "priority") as! String)!,
                                                                        name: $0.value(forKey: "name") as! String,
                                                                        creationDate: $0.value(forKey: "creationDate") as! Date,
                                                                        items: convertStringToListItems(listItemsInString: $0.value(forKey: "items") as! String )) } )
        
        for currentChecklist in checklists {
            
            /// Here we check if there is a reset time associated with a particular checklist
            guard let resetTime = CoreDataOperations.shared.fetchResetTime(checklistID: currentChecklist.checklistID) else {
                // There is no reset time set for this checklist
                continue
            }
            
            /// Here we check if we need to update the reset time of the checklist
            guard shouldChecklistBeReseted(checklistID: currentChecklist.checklistID, resetTime: resetTime) else {
                // The time is not up yet
                continue
            }
            
            // Reset the completion status of the checklist's items
            guard CoreDataOperations.shared.resetChecklistItemsCompletionStatus(checklistID: currentChecklist.checklistID) == .Success else { continue }
            
            // Update the lastResetAtTime
            guard CoreDataOperations.shared.updateLastResetAtTime(checklistID: currentChecklist.checklistID) == .Success else { continue }
            
        }
        
        checklistsArray = checklistsFetched
        checklistCollectionView.reloadData()
    }
    
    @objc func actionForLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        switch(gestureRecognizer.state) {
            
            case .began:
                guard let selectedIndexPath = checklistCollectionView.indexPathForItem(at: gestureRecognizer.location(in: checklistCollectionView)) else {
                    break
                }
                
                checklistCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            
            case .changed:
                    checklistCollectionView.updateInteractiveMovementTargetPosition(gestureRecognizer.location(in: gestureRecognizer.view!))
            case .ended:
                    checklistCollectionView.endInteractiveMovement()
            default:
                    checklistCollectionView.cancelInteractiveMovement()
                }
        
    }
    
}
