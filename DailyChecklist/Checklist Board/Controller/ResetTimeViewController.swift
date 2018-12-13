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

class ResetTimeViewController: UITableViewController {

    // TODO: - Create a logic for reset time starting from NOW or SOME OTHER SPECIFIED TIME
    // TODO: - If there is already a reset time selected, then mark it with a tick
    
    // MARK: - Local variables to be used
    let resetTimesArray:[ResetTimes] = [ResetTimes(category: .Minute, values: ["10 minutes","20 minutes","30 minutes"]),ResetTimes(category: .Hour, values: ["1 hour","2 hours","3 hours","5 hours","10 hours","12 hours","15 hours"]),ResetTimes(category: .Day, values: ["1 day","2 days"]),ResetTimes(category: .Week, values: ["1 week","2 weeks","3 weeks"]),ResetTimes(category: .Month, values: ["1 month","2 months"])]
    
    var resetTimeSelected:String?
    
    var transferDataDelegate:TransferData?
    
    // MARK: - Overriding inbuilt functions
    override func viewDidLoad() {
        super.viewDidLoad()

        customizeTableView()
        
    }

}

// MARK: - Table View Data Source
extension ResetTimeViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return resetTimesArray.count + 1 // +1 for Custom
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == resetTimesArray.count ? 1 : resetTimesArray[section].values.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CHECKLIST_SETTINGS_RESET_TIME_TABLEVIEW_CELL, for: indexPath) as! ResetTimeTableViewCell
        
        // Checking if we are at the last cell of the tableView i.e. Custom Cell
        guard !(indexPath.section == resetTimesArray.count) else {
            
            cell.timeLabel.text = "Custom"
            cell.timeLabel.textColor = UIColor(hexString: "#007AFF")
            cell.timeLabel.font = UIFont.systemFont(ofSize: 18, weight: .thin)
            
            return cell
        }
        
        cell.timeLabel.text = resetTimesArray[indexPath.section].values[indexPath.row]
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == resetTimesArray.count ? "Create your own" : "In \(resetTimesArray[section].category.rawValue)"        
    }
    
}

// MARK: - Table View Delegate
extension ResetTimeViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let selectedTime = resetTimesArray[indexPath.section].values[indexPath.row]
        
        transferDataDelegate?.updateResetTime(newResetTime: convertStringToSeconds(aString: selectedTime))
        
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
    
    // Return number of seconds which will be converted to minute,hour,day,week etc
    fileprivate func convertStringToSeconds(aString: String) -> TimeInterval {
        
        let splittedArray = aString.components(separatedBy: " ")
        
        var numberOfSecondsToBeReturned: TimeInterval = 0.0
        
        /// I am assuming the string will either be like 1 hour/10 minutes/3 weeks OR 1 hour 20 minutes/ 2 weeks 3 days , that is, first number, then string ,then number , then string and soooo on
        
//        // We are checking if the user has more than one time constraint i.e. 1 hour 30 minutes, 3 week 2 days
//        var timeHasMoreThanOneComponent = splittedArray.count > 2
        
        // Creating an array of tuple which has 2 elements , time unit(hour,minute) and its value(2,12)
        var collectionOfTimes = [(type:String,value:Int)]()
        
        // For creating collection of tuples which contain time unit and itr value
        for currentIndex in 0...splittedArray.count - 1 {
            
            // When we have odd, we can subtract 1 from it and can combine with the previous to create a tuple
            guard !currentIndex.isEven else { continue }
        
            collectionOfTimes.append((type: splittedArray[currentIndex], value: Int(splittedArray[currentIndex-1])!))
            
        }
        
        // Taking each element in the tuple and converting it to seconds and adding it to the final seconds
        for currentTime in collectionOfTimes {
            
            switch currentTime.type {
                
            case "minute","minutes":
               numberOfSecondsToBeReturned += Double(currentTime.value * 60)
                
            case "hour","hours":
               numberOfSecondsToBeReturned += Double(currentTime.value * 3600)
                
            case "day","days":
                numberOfSecondsToBeReturned += Double(currentTime.value * 86400)
                
            case "week","weeks":
                numberOfSecondsToBeReturned += Double(currentTime.value * 604800)
            
            // FIXME: - There are different values for months to seconds on the internet like 2629800 / 2629746
            case "month","months":
                numberOfSecondsToBeReturned += Double(currentTime.value * 2592000)
                
            default:
                 break
                
            }
            
        }
        
        return numberOfSecondsToBeReturned
        
    }

}



