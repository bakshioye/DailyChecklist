//
//  ChecklistSettingsViewController.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 10/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class ChecklistSettingsViewController: UIViewController {
    
    // MARK: - Outlet Variables
    @IBOutlet weak var settingsTableView: UITableView!

    // MARK: - Variables to be used
    var checklistUUID: UUID?
    
    var settings = [ChecklistSetting]()
    
    // MARK: - Overriding inbuilt functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // For removing the space above tableview's top and below the navigation bar
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        settingsTableView.tableHeaderView = UIView(frame: frame)
        
        /// Populating the setting array
        // Adding Reset Time setting
        settings.append(ChecklistSetting(icon: #imageLiteral(resourceName: "settingResetIcon"), name: .ResetTime, value: parseResetTimeToString()))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // When we go to resetTime selection VC after tapping on resetTime setting cell and come back , the cell will still be selected, so to remove this we do this fix
        if let selectedIndexRow = settingsTableView.indexPathForSelectedRow {
            settingsTableView.deselectRow(at: selectedIndexRow, animated: true)
        }
        
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
            stringToBeReturned += "\(resetTime.month) month "
        }
        if resetTime.week != 0 {
            stringToBeReturned += "\(resetTime.week) week "
        }
        if resetTime.day != 0 {
            stringToBeReturned += "\(resetTime.day) day "
        }
        if resetTime.hour != 0 {
            stringToBeReturned += "\(resetTime.hour) hour "
        }
        if resetTime.minute != 0 {
            stringToBeReturned += "\(resetTime.minute) minute "
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
        
        switch currentSetting.settingName {
        
        case .ResetTime:
            cell.settingValue.text = currentSetting.settingValue as? String
        
        }
        
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
            
            resetTimeVCObject.transferDataDelegate = self
            
            self.navigationController?.pushViewController(resetTimeVCObject, animated: true)
            
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
        
        // FIXME: - Call a method to update the reset time inside Core Data
        
        // Asking the user if they want to reset the list NOW or if they want to wait for the reset time STARTING NOW ONWARDS WITHOUT RESETTING THE LIST AT THIS VERY MOMENT
        createAlertForResetNow(newResetTimeInSeconds: newResetTime)
        
        
        
        
        
    }
   
}



