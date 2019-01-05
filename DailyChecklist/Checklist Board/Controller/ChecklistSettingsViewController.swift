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
    var resetTime:TimeInterval?
    
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
        
        if let resetTimeUnwrapped = resetTime {
            /// If the user has set some value for resetTime , handle it here
            print("Date fetched : \(resetTimeUnwrapped)")
            return "Some Date"
        }
        
        return "Not Set"
        
    }
    
    fileprivate func createAlertForResetNow(newResetTimeInSeconds: TimeInterval) {
        
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
    
//    fileprivate func convertSecondsToDateFormat(inSeconds: TimeInterval) -> String {
//        
//        
//        
//    }
    
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
    
    func updateResetTime(newResetTime: TimeInterval) {
        
        print("-------- updateResetTime() called ----------")
        
        // Asking the user if they want to reset the list now or of they want to wait for the reset time FROM NOW ON WITHOUT RESETTING THE LIST AT THIS MOMENT
        createAlertForResetNow(newResetTimeInSeconds: newResetTime)
        
        
        
        // Call a method to update the reset time inside Core Data
        
    }
   
}



