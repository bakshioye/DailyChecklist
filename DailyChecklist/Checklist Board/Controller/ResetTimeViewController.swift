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
    
    var resetTimeSelected:TimeInterval?
    
    var transferDataDelegate:TransferData?
    
    // Used to store "Custom time" from Core Data made by user in the past
    var customResetTimes = [(TimeDomain)]()
    
    // MARK: - Overriding inbuilt functions
    override func viewDidLoad() {
        super.viewDidLoad()

        customizeTableView()
        
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
            
            return cell
        }
        
        cell.timeLabel.text = resetTimesArray[indexPath.section].values[indexPath.row]
        
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
    
        // We are checking if the user tapped on the label named "Custom"
        if let cell = tableView.cellForRow(at: indexPath) as? ResetTimeTableViewCell , cell.timeLabel.text == "Custom" {
            
            let customResetTimeVCObject = self.storyboard?.instantiateViewController(withIdentifier: CHECKLIST_CUSTOM_RESET_TIME_VC_IDENTIFIER) as! CustomResetTimeViewController
            
            customResetTimeVCObject.transferDataBackDelegate = self
            
            self.navigationController?.pushViewController(customResetTimeVCObject, animated: true)
            
            return
        }
        
        let selectedTime = resetTimesArray[indexPath.section].values[indexPath.row]
        
        transferDataDelegate?.updateResetTime(newResetTime: convertStringToSeconds(aString: selectedTime))
        
        navigationController?.popViewController(animated: true)
        
    }
    
}

// MARK: - Conforming to the Transfer Data Protocol
extension ResetTimeViewController: TransferData {
    
    func customTimeSelected(inSeconds: TimeInterval) {
        
        // Here we have the custom time was selected
        resetTimeSelected = inSeconds
        
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
    
    fileprivate func convertTimeDomainToString(_ timeInDomain:TimeDomain) -> String {
        
        let monthsString = timeInDomain.month != 0 ? "\(timeInDomain.month) months " : ""
        
        let weeksString = timeInDomain.week != 0 ? "\(timeInDomain.week) weeks " : ""
        
        let daysString = timeInDomain.day != 0 ? "\(timeInDomain.day) days " : ""
        
        let hoursString = timeInDomain.hour != 0 ? "\(timeInDomain.hour) hours " : ""
        
        let minuteString = timeInDomain.minute != 0 ? "\(timeInDomain.minute) minutes " : ""
        
        return monthsString+weeksString+daysString+hoursString+minuteString
        
    }

}



