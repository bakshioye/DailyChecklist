//
//  ChecklistSettingsViewController.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 10/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class ChecklistSettingsViewController: UIViewController {
    
    /// Added a demo comment here to solve merge conflict
    
    // MARK: - Outlet Variables
    @IBOutlet weak var settingsTableView: UITableView!

    // MARK: - Programatically created views
    var prioritySelectionView: PrioritySelectionView!
    
    var prioritySelectionHeader: UILabel!
    
    // MARK: - Variables to be used
    var checklistUUID: UUID?
    
    /// The Reset time already set for the checklist, *nil otherwise*
    var resetTimeAlreadySet: TimeDomain?
    
    /// The Priority already set for checklist
    var priorityAlreadySet: ChecklistPriority?
    
    /// To transfer data to other View Controller
    var transferDataDelegate: TransferData?
    
    var settings = [ChecklistSetting]()
    
    // MARK: - Overriding inbuilt functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // For removing the space above tableview's top and below the navigation bar
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        settingsTableView.tableHeaderView = UIView(frame: frame)
        
        // Predicting what values to give to various setting as the same View Controller will be used in both the case i.e. while creating a new checklist and while editing an already created checklist
        let valueForResetTime = checklistUUID == nil ? ( resetTimeAlreadySet == nil ? "Not Set" : convertTimeDomainToString(resetTimeAlreadySet!) ) : parseResetTimeToString()
        
        /// Populating the setting array
        // Adding Reset Time setting
        settings.append(ChecklistSetting(icon: #imageLiteral(resourceName: "settingResetIcon"), name: .ResetTime, value: valueForResetTime))
        settings.append(ChecklistSetting(icon: #imageLiteral(resourceName: "prioritySettingIcon"), name: .Priority, value: priorityAlreadySet?.rawValue ?? ChecklistPriority.None.rawValue))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // When we go to resetTime selection VC after tapping on resetTime setting cell and come back , the cell will still be selected, so to remove this we do this fix
        if let selectedIndexRow = settingsTableView.indexPathForSelectedRow {
            settingsTableView.deselectRow(at: selectedIndexRow, animated: true)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // Transfer the data to the previous view controller
        if let resetTime = resetTimeAlreadySet {
            // Reset time was removed from the checklist
            transferDataDelegate?.updateResetTime(newResetTime: resetTime)
        }

        
        transferDataDelegate?.prioritySelected(priorityAlreadySet ?? .None)
    }

}

// MARK: - Helper Functions
extension ChecklistSettingsViewController {
    
    fileprivate func parseResetTimeToString() -> String {
        
        // Checking if there exists a Reset time for the checklist
        guard let resetTime = CoreDataOperations.shared.fetchResetTime(checklistID: checklistUUID!) else {
            return "Not Set"
        }
        
        var stringToBeReturned = ""
        
        // Checking if there exists a reset time and modifying the string accordingly
        if resetTime.month != 0 {
            stringToBeReturned += "\(resetTime.month) \(resetTime.month == 1 ? "month" : "months" ) "
        }
        if resetTime.week != 0 {
            stringToBeReturned += "\(resetTime.week) \(resetTime.week == 1 ? "week" : "weeks" ) "
        }
        if resetTime.day != 0 {
            stringToBeReturned += "\(resetTime.day) \(resetTime.day == 1 ? "day" : "days" ) "
        }
        if resetTime.hour != 0 {
            stringToBeReturned += "\(resetTime.hour) \(resetTime.hour == 1 ? "hour" : "hours" ) "
        }
        if resetTime.minute != 0 {
            stringToBeReturned += "\(resetTime.minute) \(resetTime.minute == 1 ? "minute" : "minutes" ) "
        }
        
        return stringToBeReturned
    }
    
    fileprivate func createAlertForResetNow(newResetTimeInSeconds: TimeDomain) {
        
        let alert = UIAlertController(title: "Reset checklist now ?", message: "Do you want to reset the checklist now ? If you select 'No', checklist will be reseted after \(newResetTimeInSeconds) ", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(yesAction)
        
        let noAction = UIAlertAction(title: "No", style: .destructive) { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)                        
        }
        
        alert.addAction(noAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    /**
        This function adds a header label above Priority Selection View
     
        - Parameter shouldBeAdded: *true* in case the header label is to be added ,*false* if it is to be removed
        - Parameter frame: If *shouldBeAdded* is true, we need to provide the frame of the Priority Selection View
     
        - Note: Pass **nil** to *selectionViewframe* in case where *shouldBeAdded* is false
    */
    
    fileprivate func prioritySelectionHeader(shouldBeAdded: Bool, selectionViewframe frame: CGRect?) {
        
        switch shouldBeAdded {
        
        case true:
            prioritySelectionHeader = UILabel(frame: CGRect(x: 0, y: frame!.minY - 70, width: self.view.viewWidth, height: 40))
            
            prioritySelectionHeader.text = "Select Checklist Priority"
            prioritySelectionHeader.textColor = UIColor(hexString: "#212121")
            prioritySelectionHeader.textAlignment = .center
            prioritySelectionHeader.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
            
            self.view.addSubview(prioritySelectionHeader)
            
        case false:
            prioritySelectionHeader.removeFromSuperview()
            
        }
        
    }
    
}


// MARK: - TableView Data Source
extension ChecklistSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CHECKLIST_SETTINGS_TABLEVIEW_CELL, for: indexPath) as! ChecklistSettingsCell
        
        let currentSetting = settings[indexPath.row]
    
        // Setting the name of the checklist setting
        cell.settingName.text = currentSetting.settingName.rawValue
        
        // Setting the image of the checklist setting
        cell.cellIcon.image = currentSetting.settingIcon
        
        // Setting the value for the checklist setting
        cell.settingValue.text = currentSetting.settingValue as? String
        
        return cell
    }
    
}

// MARK: - Table View Delegate
extension ChecklistSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedSetting = settings[indexPath.row]
        
        switch selectedSetting.settingName {
        
        case .ResetTime:
            
            // User selects from various set of time labels
            let resetTimeVCObject = self.storyboard?.instantiateViewController(withIdentifier: CHECKLIST_SETTINGS_RESET_TIME_VC_IDENTIFIER) as! ResetTimeViewController
            
            
            // If we are navigating from NewChecklistVC, then we will not have any checklistID yet! So, we first check from which View Controller we are navigating from
            
            guard checklistUUID != nil else {
                // We are navigating from NewChecklistVC
                
                resetTimeVCObject.transferDataDelegate = self
                resetTimeVCObject.resetTimeAlreadySet = resetTimeAlreadySet
                self.navigationController?.pushViewController(resetTimeVCObject, animated: true)
                break
            }
            
            // We are navigating from ChecklistVC
            resetTimeVCObject.transferDataDelegate = self
            resetTimeVCObject.checklistUUID = checklistUUID!
            resetTimeVCObject.resetTimeAlreadySet = CoreDataOperations.shared.fetchResetTime(checklistID: checklistUUID!)
            
            self.navigationController?.pushViewController(resetTimeVCObject, animated: true)
            
        case .Priority:
            
            // Adding a blur background
            blurBackgroundEffect(shouldBeAdded: true)
            
            let priorityToBePassed = priorityAlreadySet ?? ChecklistPriority.None
            
            // Setting up the view for priority selection --- Height will be 40 for one so 4 text field, we will have 160
            prioritySelectionView = PrioritySelectionView(frame: CGRect(x: 0, y: 0, width: self.view.viewWidth * 0.4, height: 160 ), priorityAlreadySet: priorityToBePassed)
            
            prioritySelectionView.center = self.view.center
            
            prioritySelectionView.transferDataDelegate = self
            
            view.addSubview(prioritySelectionView)
            
            // Adding the header for the priority selection header
            prioritySelectionHeader(shouldBeAdded: true, selectionViewframe: prioritySelectionView.frame)
            
        }
        
    }
    
}

// MARK: -  Transfer Data Protocol Conformance
extension ChecklistSettingsViewController: TransferData {
    
    func updateResetTime(newResetTime: TimeDomain) {
       
        // Since we know that the first setting in the list(or say tableView) is always Reset time so we directly fetch that cell and update its label accordingly
        if let cell = settingsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ChecklistSettingsCell {
            cell.settingValue.text = convertTimeDomainToString(newResetTime)
        }
        
        /// We are navigating from NewChecklistVC
        guard checklistUUID != nil else {
            resetTimeAlreadySet = newResetTime
            return
        }
        
        /// We are navigating from ChecklistVC               
        // Updating the Core Data with the updated reset time
        CoreDataOperations.shared.updateResetTime(newResetTime, checklistID: checklistUUID!)
        
        
        // Asking the user if they want to reset the list NOW or if they want to wait for the reset time STARTING NOW ONWARDS WITHOUT RESETTING THE LIST AT THIS VERY MOMENT
//        createAlertForResetNow(newResetTimeInSeconds: newResetTime)
        
    }
    
    func removeResetTime() {
        
        // Updating the label
        if let cell = settingsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ChecklistSettingsCell {
            cell.settingValue.text = "Not Set"
        }
        
        // Removing the reset time for this VC as in viewDidDisappear(), we are passing the resetTime value from this VC to previous VC
        resetTimeAlreadySet = nil
        
        // Removing the reset time for previous controller
        transferDataDelegate?.removeResetTime()
        
    }
    
    func prioritySelected(_ priority: ChecklistPriority) {
        
        priorityAlreadySet = priority
        
        // Updating the setting label's value
        if let cell = settingsTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ChecklistSettingsCell {
            cell.settingValue.text = priority.rawValue
        }
        
        // Removing the Blur Background as well as Selection View
        blurBackgroundEffect(shouldBeAdded: false)
        
        prioritySelectionView.removeFromSuperview()
        prioritySelectionHeader(shouldBeAdded: false, selectionViewframe: nil)
    }
   
}



