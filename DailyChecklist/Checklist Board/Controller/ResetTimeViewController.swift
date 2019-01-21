//
//  ResetTimeViewController.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 11/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

fileprivate enum TimeDomainsType: String {
    case Minute
    case Minutes
    case Hour
    case Hours
    case Day
    case Days
    case Week
    case Weeks
    case Month
    case Months
}

/// This will help in determing which VC presented this vc and thus we can take the necessary step
fileprivate enum PresentedViewController {
    case NewChecklistVC
    case ChecklistSettingVC
}

class ResetTimeViewController: UITableViewController {

    // TODO: - Create a logic for reset time starting from NOW or SOME OTHER SPECIFIED TIME
    // TODO: If there is already a reset time selected, then mark it with a tick


    // MARK: - Local variables to be used
    var resetTimesArray:[ResetTimes] = [ResetTimes(category: .Minute, values: ["10 minutes","20 minutes","30 minutes"]),
                                        ResetTimes(category: .Hour, values: ["1 hour","2 hours","3 hours","5 hours","10 hours","12 hours","15 hours"]),
                                        ResetTimes(category: .Day, values: ["1 day","2 days"]),
                                        ResetTimes(category: .Week, values: ["1 week","2 weeks","3 weeks"]),
                                        ResetTimes(category: .Month, values: ["1 month","2 months"]) ]
    
    
    /// The Reset time already set for the checklist, *nil otherwise*
    var resetTimeAlreadySet: TimeDomain?
    
    /// **TransferData** object used to transfer data to the previous View Controller
    var transferDataDelegate:TransferData?
    
    /// ID for the checklist for which the reset time is to be modified
    var checklistUUID: UUID?
    
    /// Used to store "Custom time" from Core Data made by user in the past
    var customResetTimes = [TimeDomain]()
    
    /// This will signify which View controller presented this View Controller
    fileprivate var viewControllerThatPresentedThis: PresentedViewController!
    
    // MARK: - Overriding inbuilt functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Checking which View Controller presented this and assigning the value accordingly
        if let viewControllerThatPresentedThis = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2], viewControllerThatPresentedThis is NewChecklistViewController {
            self.viewControllerThatPresentedThis = PresentedViewController.NewChecklistVC
        }
        else {
            self.viewControllerThatPresentedThis = PresentedViewController.ChecklistSettingVC
        }
        
        customizeTableView()
        
        addNavigationBarButtons()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        customResetTimes = CoreDataOperations.shared.fetchSavedCustomResetTime()
        
        /// We are reloading here as when we come back after creating our own custom time, it will be reflected here
        tableView.reloadData()
        
    }

}

// MARK: - Table View Data Source
extension ResetTimeViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        //If there are any custom Reset Times, we are allocating 1 section to that
        let areThereCustomResetTimes = customResetTimes.count == 0 ? 0 : 1
        
        return resetTimesArray.count + areThereCustomResetTimes + 1 // +1 for Custom
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        
        case resetTimesArray.count where customResetTimes.count > 0 : /// There are some custom reset time rows
            return customResetTimes.count
            
        case resetTimesArray.count where customResetTimes.count == 0: /// There are no custom reset time rows so this will be "Custom" named row
            return 1
            
        // Will always be the last section no matter what
        case resetTimesArray.count + 1: /// There are some custom reset time rows but this is the "Custom" named row
            return 1
        
        default: /// For all the other time rows
            return resetTimesArray[section].values.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CHECKLIST_SETTINGS_RESET_TIME_TABLEVIEW_CELL, for: indexPath) as! ResetTimeTableViewCell
        
        // Checking if we are at the last cell of the tableView i.e. Custom Cell
        guard !((indexPath.section == resetTimesArray.count && customResetTimes.count == 0) || indexPath.section == resetTimesArray.count + 1) else {
            
            cell.timeLabel.text = "Custom"
            cell.timeLabel.textColor = UIColor(hexString: "#007AFF")
            cell.timeLabel.font = UIFont.systemFont(ofSize: 18, weight: .thin)
            
            return cell
        }
        
        // Checking if there are some custom reset time available
        guard !(indexPath.section == resetTimesArray.count && customResetTimes.count > 0) else {
            
            cell.timeLabel.text = convertTimeDomainToString(customResetTimes[indexPath.row])
            
            // Changing the background color for already selected cell
            if let resetTimeAlreadySet = resetTimeAlreadySet, resetTimeAlreadySet == customResetTimes[indexPath.row] {
                
                cell.contentView.backgroundColor = UIColor(hexString: "#e6ee9c")
                
            }
            
            return cell
        }
        
        cell.timeLabel.text = resetTimesArray[indexPath.section].values[indexPath.row]
        
        // Changing the background color for already selected cell
        if let resetTimeAlreadySet = resetTimeAlreadySet, resetTimeAlreadySet == convertStringToTimeDomain(resetTimesArray[indexPath.section].values[indexPath.row]) {
            
            cell.contentView.backgroundColor = UIColor(hexString: "#e6ee9c")
            
        }
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            
        case resetTimesArray.count where customResetTimes.count > 0 : /// There are some custom reset time rows
            return "You created these earlier"
            
        case resetTimesArray.count where customResetTimes.count == 0: /// There are no custom reset time rows so this will be "Custom" named row
            return "Create your own"
            
        // Will always be the last section no matter what
        case resetTimesArray.count + 1: /// There are some custom reset time rows but this is the "Custom" named row
            return "Create your own"
            
        default: /// For all the other time rows
            return "In \(resetTimesArray[section].category.rawValue)"
        }
        
    }
    
}

// MARK: - Table View Delegate
extension ResetTimeViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        // User tapped "Custom"
        if let cell = tableView.cellForRow(at: indexPath) as? ResetTimeTableViewCell , cell.timeLabel.text == "Custom" {
            
            let customResetTimeVCObject = self.storyboard?.instantiateViewController(withIdentifier: CHECKLIST_CUSTOM_RESET_TIME_VC_IDENTIFIER) as! CustomResetTimeViewController
            
            self.navigationController?.pushViewController(customResetTimeVCObject, animated: true)
            
            return
        }
        
        // User tapped on a custom time that they defined OR User tapped on pre defined time
        let selectedTime = indexPath.section >= resetTimesArray.count ? convertTimeDomainToString(customResetTimes[indexPath.row]) : resetTimesArray[indexPath.section].values[indexPath.row]
        
        let selectedTimeInTimeDomain = convertStringToTimeDomain(selectedTime)
        
        transferDataDelegate?.updateResetTime(newResetTime: selectedTimeInTimeDomain)
        
        navigationController?.popViewController(animated: true)
        
    }
    
}

// MARK: - Helper Functions
extension ResetTimeViewController {
    
    fileprivate func customizeTableView() {
        
        // Add some space at the end of table view
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        tableView.contentInset = insets
        
    }
    
    fileprivate func addNavigationBarButtons() {
        
        // Adding the Remove reset time button
        let removeResetTimeButton = UIBarButtonItem(title: "Remove", style: .done, target: self, action: #selector(actionForRemoveResetTime(_:)))
        
        removeResetTimeButton.tintColor = UIColor.red
        
        navigationItem.rightBarButtonItem = removeResetTimeButton
        
    }
    
    @objc func actionForRemoveResetTime(_ button: UIBarButtonItem) {
        
        // Since , when we are creating a new checklist, we are not saving the reset time in core data unless the user clicks "Save" , we need not perform this core data operation
        if viewControllerThatPresentedThis == PresentedViewController.ChecklistSettingVC {
            if CoreDataOperations.shared.removeResetTime(checklistUUID: checklistUUID!) == .Failure {
            presentErrorAlert(title: "Error -- Reset time could not be removed", message: "The reset time linked to the checkist could not be removed at the moment, Please try again")
            }
        }
        
        // Setting the Reset Time label to Not Set
        transferDataDelegate?.removeResetTime()
        
        // Going back to the previous screen
        navigationController?.popViewController(animated: true)
        
    }
    
    
}



