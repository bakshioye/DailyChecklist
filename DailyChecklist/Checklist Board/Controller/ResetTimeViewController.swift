//
//  ResetTimeViewController.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 11/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class ResetTimeViewController: UITableViewController {

    ///Create a logic for reset time starting from NOW or SOME OTHER SPECIFIED TIME
    
    // MARK: - Local variables to be used
    let resetTimesArray = ["10 minutes","30 minutes","1 hour","2 hours","3 hours","5 hours","10 hours","12 hours","15 hours","1 day","2 days","1 week","2 weeks","3 weeks","1 month","2 months"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}

// MARK: - Table View Data Source
extension ResetTimeViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // 1 for all inside the array and 1 for Custom
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? resetTimesArray.count : 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CHECKLIST_SETTINGS_RESET_TIME_TABLEVIEW_CELL, for: indexPath) as! ResetTimeTableViewCell
        
        switch indexPath.section {
            
        case 0:
            cell.timeLabel.text = "Every \(resetTimesArray[indexPath.row])"
            
        case 1:
            cell.timeLabel.text = "Custom"
            cell.timeLabel.textColor = UIColor.blue
            cell.timeLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
            
        default:
            break
        }
        
        return cell
        
    }
    
}
