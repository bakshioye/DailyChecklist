//
//  NewChecklistViewController.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 03/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class NewChecklistViewController: UIViewController {

    // MARK: - Outlet Variables
    @IBOutlet weak var checklistNameField: UITextField!
    @IBOutlet weak var checklistNameBottomBorder: UIView!
    
    @IBOutlet weak var checklistTableView: UITableView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    // MARK: - Variables to be used
    
    /// Collection of all the cheecklist items or tasks
    var checklistItems = [ListItem]()
    
    /// The reset time selected for the checklist . **Can be nil**
    var resetTimeSelected: TimeDomain?
    
    /// The priority selected for the checklist . **Can be nil**
    var prioritySelected: ChecklistPriority?
    
    /**
        Used to store all the checklist items entered by user
     
        - Note: It will be used when we are calling prepareForReuse() and furthur cellForRowAtIndexPath()
    */
    var itemsNameArray = [String]()
    
    // MARK: - Overriding inbuilt functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Removing the seperator line between table view cells
        checklistTableView.separatorStyle = .none

        // Setting the delegate for the Checklist Name textField
        checklistNameField.delegate = self
        
        // Capitalises the first letter of the sentence
        checklistNameField.autocapitalizationType = .sentences
        
        // Changing the text on the keyboard from "return" to "done"
        checklistNameField.returnKeyType = .done
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checklistNameField.becomeFirstResponder()
    }
    
    // MARK: - Button Actions
    @IBAction func actionSave(_ saveButton: UIBarButtonItem) {
        
        // Empty the checklistItems array of the garbage data
        checklistItems.removeAll()
        
        // Fetching all the checklist items
        checklistItems = fetchChecklistItems()
        
        // Creating an index for the new checklist
        let indexForNewChecklist = CoreDataOperations.shared.fetchChecklists() != nil ? CoreDataOperations.shared.fetchChecklists()!.count + 1 : 1
        
        // We created a seperate variable as we needed a checklistID for Reset Time
        let checklistToBeCreated = Checklist(index: indexForNewChecklist, priority: prioritySelected ?? .None, name: checklistNameField.text!, creationDate: Date(), items: checklistItems)
        
        // Inserting the Checklist into Core Data and checking the response
        guard CoreDataOperations.shared.createNewChecklist(checklist: checklistToBeCreated) == .Success else {
            
            // There was failure in creating checklist
            presentErrorAlert(title: "Checklist could not be created", message: "There was an error creating checklist at the moment, Please try again")
            return
            
        }
        
        // Inserting the Reset time for the same by checking whether the user has opted to insert a reset time for the checklist
        if let resetTimeUnwrapped = resetTimeSelected {
            _ = CoreDataOperations.shared.updateResetTime(resetTimeUnwrapped, checklistID: checklistToBeCreated.checklistID)
        }
        
        
        // Going back to HomeVC
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func actionSettingsPage(_ addResetTimeButton: UIButton) {
        
        // Creating the object for navigation
        let checklistSettingVCObject = self.storyboard?.instantiateViewController(withIdentifier: CHECKLIST_SETTINGS_VC_IDENTIFIER) as! ChecklistSettingsViewController
        
        checklistSettingVCObject.transferDataDelegate = self
        
        // If we have already selected a reset time and user wants to either change or remove the already setted reset time
        if resetTimeSelected != nil {
            checklistSettingVCObject.resetTimeAlreadySet = resetTimeSelected
        }
        
        checklistSettingVCObject.priorityAlreadySet = prioritySelected ?? ChecklistPriority.None
        
        // Pushing the View Controller on the Navigation Stack
        self.navigationController?.pushViewController(checklistSettingVCObject, animated: true)
        
    }

}

// MARK: - Helper functions
extension NewChecklistViewController {
    
    fileprivate func fetchChecklistItems() -> [ListItem] {
        
       var listItemsArray = [ListItem]()
        
        for currentIndex in 0...checklistTableView.numberOfRows(inSection: 0) - 2 { // -1 for Add more row and -1 since array is 0 index based and numberOfRows returns 1 index based result
            
            // Checking if the cell is Checklist Item cell
            guard let cell = checklistTableView.cellForRow(at: IndexPath(row: currentIndex, section: 0)) as? NewChecklistTableViewCell else {
                continue
            }
            
            // Checking if the list has some item(or text) or not
            guard cell.itemNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
                continue
            }
            
            // Fetching the item name
            guard let itemName = cell.itemNameField.text else {
                continue
            }
            
            
            
            listItemsArray.append(ListItem(name: itemName, isCompleted: false))
            
        }
        
       return listItemsArray
    }
    
    
    
}

// MARK: - Table View Data Source
extension NewChecklistViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 1 for by-default displaying add item and 1 for Add more button
        return 2 + checklistItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // To check if we are at the last row and creating Add More cell accordingly
        guard indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ADD_MORE_TABLEVIEW_CELL_ID, for: indexPath) as! AddMoreTableViewCell
            
            return cell
        }
        
        // We are entering checklist items, so display that cell accordingly
        let cell = tableView.dequeueReusableCell(withIdentifier: NEW_CHECKLIST_TABLEVIEW_CELL_ID, for: indexPath) as! NewChecklistTableViewCell
        
        cell.itemNameField.delegate = self
        cell.itemNameField.becomeFirstResponder()
        
        // Used to identify which table's cell is being edited
        cell.itemNameField.tag = indexPath.row
        
        // Checking if there is already some data inside for the cell's text field
        // This will only be called when we are scrolling and prepareForReuse() is being called
        if itemsNameArray.indices.contains(indexPath.row) {
            cell.itemNameField.text = itemsNameArray[indexPath.row]
        }
        
        return cell
        
    }
    
}

// MARK: - Table View Delegate
extension NewChecklistViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Checking if the table view cell is Add More or New Checklist cell
        switch tableView.cellForRow(at: indexPath) {
        
        case is AddMoreTableViewCell :
            
            // Checking if there is already some empty cell for entering the item before adding a new cell
            let cell = tableView.cellForRow(at: IndexPath(row: indexPath.row - 1, section: indexPath.section)) as! NewChecklistTableViewCell
            
            guard let textField = cell.itemNameField else {
                return
            }
            
            if textField.text?.count == 0 || (textField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
                
                // There is an empty NewChecklist row above, so we need not add one more row
                // We are animating for the animating text field
                
                // Resetting the text so that placeholder will appear
                textField.text = ""
                
                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                    textField.layer.backgroundColor = UIColor(hexString: "#7cb342").cgColor
                }) { (Bool) in
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                        textField.layer.backgroundColor = UIColor.clear.cgColor
                    }, completion: nil)
                }
                
                return
                
            }
            
            // We are just appending some garbage data to the checklistItems as in order to increase the rows upon clicking AddMore button, we need to increase the array otherwise the app will crash
            checklistItems.append(ListItem(name: "Some Garbage data", isCompleted: false))
            tableView.insertRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .bottom)

        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
}

// MARK: - Transfer Data Protocol Implementation
extension NewChecklistViewController: TransferData {
    
    func updateResetTime(newResetTime: TimeDomain) {
        // Making the reset time global to use
        resetTimeSelected = newResetTime
    }
    
    func removeResetTime() {
        // Removing the reset time selected by the user
        resetTimeSelected = nil
    }
    
    func prioritySelected(_ priority: ChecklistPriority) {
        prioritySelected = priority
    }
    
}

// MARK: - TextField Delegate
extension NewChecklistViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == checklistNameField {
            checklistNameBottomBorder.backgroundColor = UIColor(hexString: "#4caf50")
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == checklistNameField {
            checklistNameBottomBorder.backgroundColor = UIColor.darkGray
            return
        }
        
        /// Appending the text inside the array so that when we scroll down and then back up,it calls prepareForReuse() and furthur cellForRowAtIndexPath() , it would know what data to put inside the cell when we scroll back up instead of just clearing all the text inside the textField
        if itemsNameArray.indices.contains(textField.tag) {
            itemsNameArray[textField.tag] = textField.text!
        }
        else { // We dont have cell for that text inside array
            itemsNameArray.append(textField.text!)
        }
        
    
    }
    
    
    // Called when return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // To hide the keyboard when return key is tapped on the keyboard
        self.view.endEditing(true)
        return false
        
    }
    
    
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        switch textField {
//
//        case checklistNameField :
//
//            guard (textField.text?.count)! > 0 else {
//                saveButton.isEnabled = false
//                break
//            }
//
//
//        // All the other text fields of table view will come under here
//        default :
//            guard (textField.text?.count)! > 0 && (checklistNameField.text?.count)! > 0 else {
//                saveButton.isEnabled = false
//                break
//            }
//
//            saveButton.isEnabled = true
//
//        }
//
//        return true
//
//    }
    
    
}
