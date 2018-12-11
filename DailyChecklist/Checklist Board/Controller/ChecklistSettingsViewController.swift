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
    var resetTime:Date?
    
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
            
            self.navigationController?.pushViewController(resetTimeVCObject, animated: true)
            
        }
        
    }
    
}




