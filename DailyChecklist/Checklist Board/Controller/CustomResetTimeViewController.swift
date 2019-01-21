//
//  CustomResetTimeViewController.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 17/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

fileprivate enum PickerViewVisibility {
    case Show
    case Hide
}

class CustomResetTimeViewController: UIViewController {

    // MARK: - Outlet Variables
    @IBOutlet weak var resetTimeTableView: UITableView!
    
    // MARK: - Programatically created elements
    var resetTimePickerView: UIPickerView!
    
    var toolbarForPickerView: UIToolbar!
    
    var labelForDomainDisplay: UILabel!
    
    
    // MARK: - Variables to be used
    let collectionOfResetTimeDomains: [ArrayWithLabel<ResetTimeType,Int>] = [ ArrayWithLabel(name: ResetTimeType.Minute, values: Array(1...59)),ArrayWithLabel(name: ResetTimeType.Hour, values: Array(1...23)),ArrayWithLabel(name: ResetTimeType.Day, values: Array(1...6)),ArrayWithLabel(name: ResetTimeType.Week, values: Array(1...4)),ArrayWithLabel(name: ResetTimeType.Month, values: Array(1...11)) ]
    
    // Using this, we can keep track of which time domain is to be used
    var currentSelectedTimeDomain: ResetTimeType!
    
    // We are using this variable to make changes to the time selected and updating it accordingly
    var resetTimeSelected: TimeDomain = (0,0,0,0,0) {
        willSet {
            // FIXME: - Instead of reloading complete table, reload the particular domain row
            /// When we are making the above change, we need to reload the first section ALWAYS, as we have set the updated time in the footer of the first section
            resetTimeTableView.reloadData()
        }
    }
    
    
    // MARK: - Overriding inbuilt functions
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        
        setupPickerView()
        
    }

}

// MARK: - TableView Data source
extension CustomResetTimeViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return collectionOfResetTimeDomains.count + 1 // +1 for "Save for future row"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        
        case 0: /// For "Save for future" row
            return tableView.dequeueReusableCell(withIdentifier: CHECKLIST_CUSTOM_RESET_TIME_TABLEVIEW_CELL_SAVE, for: indexPath) as! CustomResetTimeSaveCell
        
        default: /// For all other time domain rows
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CHECKLIST_CUSTOM_RESET_TIME_TABLEVIEW_CELL_DOMAIN, for: indexPath) as! CustomResetTimeDomainCell
            
            let currentTimeDomain = collectionOfResetTimeDomains[indexPath.section-1].name
            
            cell.timeDomainNameLabel.text = currentTimeDomain.rawValue
            
            // Checking if there is some time domain selected already or whether the table view is loaded for the first time
            guard let currentSelectedTimeDomainUnwrapped = currentSelectedTimeDomain else { return cell }
            
            // Making sure we are updating only the correct row that was changed and not all the rows
            guard currentTimeDomain == currentSelectedTimeDomainUnwrapped else { return cell }
            
            switch currentSelectedTimeDomainUnwrapped {
                
            case .Minute:
                cell.timeDomainValueLabel.text = String(resetTimeSelected.minute)
           
            case .Hour:
                cell.timeDomainValueLabel.text = String(resetTimeSelected.hour)
            
            case .Day:
                cell.timeDomainValueLabel.text = String(resetTimeSelected.day)
            
            case .Week:
                cell.timeDomainValueLabel.text = String(resetTimeSelected.week)
            
            case .Month:
                cell.timeDomainValueLabel.text = String(resetTimeSelected.month)
                
            }
            
            return cell
            
        }
        
    }
    
}

// MARK: - TableView Delegate
extension CustomResetTimeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // If the user selected the "Save for future" row
        if tableView.cellForRow(at: indexPath) is CustomResetTimeSaveCell { return }
        
        // Assigning the type of ResetTime domain
        currentSelectedTimeDomain = collectionOfResetTimeDomains[indexPath.section - 1].name
        
        pickerViewVisibility(will: .Show)
        
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        // We are displaying the time selected by the user only under the first section
        guard section == 0 else { return "" }
        
        let monthsString = resetTimeSelected.month != 0 ? "\(resetTimeSelected.month) months " : ""
        
        let weeksString = resetTimeSelected.week != 0 ? "\(resetTimeSelected.week) weeks " : ""
        
        let daysString = resetTimeSelected.day != 0 ? "\(resetTimeSelected.day) days " : ""
        
        let hoursString = resetTimeSelected.hour != 0 ? "\(resetTimeSelected.hour) hours " : ""
        
        let minuteString = resetTimeSelected.minute != 0 ? "\(resetTimeSelected.minute) minutes " : ""
        
        return monthsString+weeksString+daysString+hoursString+minuteString
        
    }
    
}

// MARK: - Picker View Data Source
extension CustomResetTimeViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        guard currentSelectedTimeDomain != nil else {
            return 0
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        guard currentSelectedTimeDomain != nil else {
            return 0
        }
        
        for currentArrayElement in collectionOfResetTimeDomains {
            if currentArrayElement.name == currentSelectedTimeDomain {
                return currentArrayElement.values.count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
}

// MARK: - Picker View Delegate
extension CustomResetTimeViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        for currentArrayElement in collectionOfResetTimeDomains {
            if currentArrayElement.name == currentSelectedTimeDomain {
                return String(currentArrayElement.values[row])
            }
        }
        
        return ""
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        guard let currentSelectedDomainUnwrapped = currentSelectedTimeDomain else {
            pickerViewVisibility(will: .Hide)
            return
        }
        
        // Traversing the collection to fetch the exact element that was selected
        for currentArrayElement in collectionOfResetTimeDomains {
            
            if currentArrayElement.name == currentSelectedDomainUnwrapped {
                
                switch currentSelectedDomainUnwrapped {
                
                case ResetTimeType.Minute:
                    resetTimeSelected.minute = currentArrayElement.values[row]
                
                case ResetTimeType.Hour:
                    resetTimeSelected.hour = currentArrayElement.values[row]
                    
                case ResetTimeType.Day:
                    resetTimeSelected.day = currentArrayElement.values[row]
                    
                case ResetTimeType.Week:
                    resetTimeSelected.week = currentArrayElement.values[row]
                    
                case ResetTimeType.Month:
                    resetTimeSelected.month = currentArrayElement.values[row]
                    
                }
                break
                
            }
            
        }
        
        pickerViewVisibility(will: .Hide)
        
    }
    
}

// MARK: - Helper Functions
extension CustomResetTimeViewController {
    
    fileprivate func setupPickerView() {
        
        // For iPhone that supports safe area insets
        if #available(iOS 11.0, *) {
            
            guard let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets else { return }
            
            let safeAreaHeight = self.view.viewHeight - (safeAreaInsets.top + safeAreaInsets.bottom)
            let safeAreaWidth = self.view.viewWidth - (safeAreaInsets.left + safeAreaInsets.right)
            
            resetTimePickerView = UIPickerView(frame: CGRect(x: 0, y: (self.view.frame.maxY - safeAreaInsets.bottom) - safeAreaHeight / 3, width: safeAreaWidth, height: safeAreaHeight / 3))
        }
        else {
            resetTimePickerView = UIPickerView(frame: CGRect(x: 0, y: self.view.frame.maxY - self.view.viewHeight / 3, width: self.view.viewWidth, height: self.view.viewHeight / 3))
        }
        
        resetTimePickerView.showsSelectionIndicator = true
        resetTimePickerView.backgroundColor = UIColor(hexString: "#e0e0e0")
        
        resetTimePickerView.dataSource = self
        resetTimePickerView.delegate = self
        
        // Setting up the toolbar for picker view
        toolbarForPickerView = UIToolbar(frame: CGRect(x: 0, y: resetTimePickerView.frame.minY - 50, width: resetTimePickerView.viewWidth, height: 50))
        
        toolbarForPickerView.backgroundColor = UIColor(hexString: "#eeeeee")
        
        toolbarForPickerView.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionForCancelButtonToolbar))]
        
        
        // Setting the label for the Toolbar
        /// Here we created a label and imposed it on top of the toolbar which appears as if the label is inside the toolbar but it is actually on top of it
        labelForDomainDisplay = UILabel(frame: CGRect(x: 0.25*toolbarForPickerView.viewWidth, y: resetTimePickerView.frame.minY - 50, width: toolbarForPickerView.viewWidth/2, height: 50))
        labelForDomainDisplay.textColor = UIColor(hexString: "#424242")
        labelForDomainDisplay.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        labelForDomainDisplay.textAlignment = .center
        
    }
    
    fileprivate func setupNavigationBar() {
        
        self.navigationItem.title = "Custom"
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionForDoneButton))
        
        self.navigationItem.rightBarButtonItem = doneBarButton
        
    }
    
    fileprivate func pickerViewVisibility(will visibility: PickerViewVisibility) {
        
        switch visibility {
        
        case .Show:
                // Adding the blur view background for picker view
                blurViewBackgroundVisibility(will: .Show)
                
                // Adding the Toolbar and Picker View
                self.view.addSubview(resetTimePickerView)
                self.view.addSubview(toolbarForPickerView)
                
                // Changing the domain label text and displaying it
                labelForDomainDisplay.text = " Select \(currentSelectedTimeDomain.rawValue)"
                self.view.addSubview(labelForDomainDisplay)
                
                // Since adding Picker View won't refresh the components for different domains, so we need to manually refresh it
                resetTimePickerView.reloadAllComponents()
            
                /// When we were switching between different domains, new domain will start from the index of the last domain we selected and not index 0
                resetTimePickerView.selectRow(0, inComponent: 0, animated: false)
                preparePickerViewForAlreadySelectedTime()
            
        case .Hide:
                // Removing the Toolbar and Picker View
                resetTimePickerView.removeFromSuperview()
                toolbarForPickerView.removeFromSuperview()
                labelForDomainDisplay.removeFromSuperview()
                
                // Remove the blur background after remvoving the Picker  View
                blurViewBackgroundVisibility(will: .Hide)
        }
        
    }
    
    fileprivate func preparePickerViewForAlreadySelectedTime() {
        
        guard let currentSelectedTimeDomainUnwrapped = currentSelectedTimeDomain else { return }
        
        switch currentSelectedTimeDomainUnwrapped {
        
        case .Minute:
            if resetTimeSelected.minute != 0 {
                resetTimePickerView.selectRow(resetTimeSelected.minute - 1, inComponent: 0, animated: true)
            }
        
        case .Hour:
            if resetTimeSelected.hour != 0 {
                resetTimePickerView.selectRow(resetTimeSelected.hour - 1, inComponent: 0, animated: true)
            }
        
        case .Day:
            if resetTimeSelected.day != 0 {
                resetTimePickerView.selectRow(resetTimeSelected.day - 1, inComponent: 0, animated: true)
            }
        
        case .Week:
            if resetTimeSelected.week != 0 {
                resetTimePickerView.selectRow(resetTimeSelected.week - 1, inComponent: 0, animated: true)
            }
        
        case .Month:
            if resetTimeSelected.month != 0 {
                resetTimePickerView.selectRow(resetTimeSelected.month - 1, inComponent: 0, animated: true)
            }
        
        }
        
    }
    
    fileprivate func blurViewBackgroundVisibility(will visibility: PickerViewVisibility) {
        
        switch visibility {
        
        case .Show:
            // Creating a blur effect
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
            
            // Main Blur Effect View
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = resetTimeTableView.frame
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // We are providing this tag so that we can remove this Blur View later
            blurEffectView.tag = 1001
            
            view.addSubview(blurEffectView)
            
        case .Hide:
            
            if let viewWithTag1001 = self.view.viewWithTag(1001) {
                viewWithTag1001.removeFromSuperview()
            }
            
        }
        
    }
    
    fileprivate func convertSelctedTimeToSeconds() -> TimeInterval {
        
        var selectedTimeInSeconds:TimeInterval = 0
        
        selectedTimeInSeconds += Double(resetTimeSelected.minute * 60)
        
        selectedTimeInSeconds += Double(resetTimeSelected.hour * 3600)
        
        selectedTimeInSeconds += Double(resetTimeSelected.day * 86400)
        
        selectedTimeInSeconds += Double(resetTimeSelected.week * 604800)
        
        selectedTimeInSeconds += Double(resetTimeSelected.month * 2592000)
        
        return selectedTimeInSeconds
        
    }

    
    @objc func actionForDoneButton() {
        
        // Checking if the user wants to save this custom time for future use
        /// Save this time into some persistent storage like Core Data or User Defaults
        if let cell = resetTimeTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CustomResetTimeSaveCell, cell.saveForFutureSwitch.isOn {
            
            guard CoreDataOperations.shared.saveCustomResetTime(resetTimeSelected) == .Success else {
                presentErrorAlert(title: "Custom reset time could not be saved", message: "The custom reset time that you have specified could not be saved at this moment, Please check the time once again!")
                return
            }
            
        }
        
        /// Fetch the selected time and transfer it to the ViewController before
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func actionForCancelButtonToolbar() {
        resetTimePickerView.removeFromSuperview()
        toolbarForPickerView.removeFromSuperview()
        labelForDomainDisplay.removeFromSuperview()
        
        blurViewBackgroundVisibility(will: .Hide)
    }
    
}






