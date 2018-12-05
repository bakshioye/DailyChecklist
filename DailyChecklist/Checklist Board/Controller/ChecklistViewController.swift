//
//  ChecklistViewController.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 15/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit
import CoreData

class ChecklistViewController: UIViewController {

    // MARK: - Outlet Variables
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var parentViewForTitleLabel: UIView!
    @IBOutlet weak var checklistTableView: UITableView!
    
    // MARK: - Programatically created UI Elements
    var textFieldForChecklistName: UITextField!
    
    // MARK: - Custom variables to be created
    var checklist:Checklist!
    
    var selectedChecklist:NSManagedObject? // This will contain the user selected checklist as returned from Core Data
    
    // MARK: - Overiding inbuilt functions
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Disabling the Large title text for view controller
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Removing the seperator line between table view cells
        checklistTableView.separatorStyle = .none
    
        setupChecklist()
    }
    

    //MARK: - Actions for buttons
    @IBAction func actionEditName(_ sender: UIButton) {
        
        
        
    }
    
}

// MARK: - Helper functions
extension ChecklistViewController {
    
    fileprivate func setupChecklist() {
        
        guard let selectedChecklistUnwrapped = selectedChecklist else {
            presentErrorAlert(title: "Could not load checklist", message: "The checklist could not be loaded as there was some error, Please remove the checklist and try again")
            return
        }
        
        // Converting the List items recieved from database in form of String to ListItem format
        let checklistItems = fetchListItemsFromString(listItemsInString: selectedChecklistUnwrapped.value(forKey: "items") as! String)
        
        // Creating the instance of the checklist
        checklist = Checklist(name: selectedChecklistUnwrapped.value(forKey: "name") as! String, creationDate: selectedChecklistUnwrapped.value(forKey: "creationDate") as! Date, resetTime: selectedChecklistUnwrapped.value(forKey: "resetTime") as? Date, items: checklistItems)
        
        // Setting the name of the checklist
        titleLabel.text = checklist.name
        
        // Sorting the array based on boolean values - false(not yet completed) first and then true(completed) after that
        checklist.items.sort( by: { $1.isCompleted } )
        
    }
    
    fileprivate func fetchListItemsFromString(listItemsInString: String) -> [ListItem] {
        
        var listItemArray = [ListItem]()
        
        let arrayOfItems = listItemsInString.components(separatedBy: "\\i")
      
        for currentItem in arrayOfItems {
            
            // 0 position will have name of the item and 1 positon will have the status of that item
            let tempArray = currentItem.components(separatedBy: "\\b")

            listItemArray.append(ListItem(name: tempArray[0], isCompleted: Bool(tempArray[1])!))
        }
        
        return listItemArray
        
    }
    
}

// MARK: - Table View Data Source
extension ChecklistViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist.items.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /// when we just have the last row i.e. add more row
        if indexPath.row == checklist.items.count {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ADD_MORE_TABLEVIEW_CELL_ID, for: indexPath) as! AddMoreTableViewCell
            
            return cell
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CHECKLIST_TABLEVIEW_CELL_ID, for: indexPath) as! ChecklistTableViewCell
        
        cell.taskStatusDelegate = self
        cell.checklistItemField.delegate = self
        
        // Assigning tags to various entities for fetching indexPath.row for a particular cell where we cannot access the tableView and thus cannot acess the indexPath.row
        cell.tag = indexPath.row
        cell.checklistItemField.tag = indexPath.row
        
        let taskName = checklist.items[indexPath.row].name
        
        var strikeThroughEffect = Dictionary<NSAttributedString.Key,Any>()
        
        if checklist.items[indexPath.row].isCompleted {
            // Task Completed
            cell.taskStatus.taskCompleted = true
            
            //Making a strike through text for completed tasks
            strikeThroughEffect = [ NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                                                                        NSAttributedString.Key.strikethroughColor: UIColor.darkGray ]
            
            cell.checklistItemLabel.textColor = UIColor.darkGray
        }
        else {
            
            cell.taskStatus.taskCompleted = false
            
            cell.checklistItemLabel.textColor = UIColor.black
            
            //Removing the attributes set earlier
            strikeThroughEffect.removeAll()
        }
        
        let attributedString = NSAttributedString(string: taskName, attributes: strikeThroughEffect)
        cell.checklistItemLabel.attributedText = attributedString
        
        return cell
        
    }
    
    
    
}

// MARK: - Table View Delegate
extension ChecklistViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let selectedCell = tableView.cellForRow(at: indexPath)
        
        switch selectedCell {
        
        case is ChecklistTableViewCell :
            
            // Editing the already existing item's name
            
            let cell = tableView.cellForRow(at: indexPath) as! ChecklistTableViewCell
            
            cell.checklistItemField.isHidden = false
            cell.checklistItemField.placeholder = cell.checklistItemLabel.text
            cell.checklistItemField.becomeFirstResponder()
            
        case is AddMoreTableViewCell :
            
            // Checking if there is already some empty cell for entering the item before adding a new cell
            let cell = tableView.cellForRow(at: IndexPath(row: indexPath.row - 1, section: indexPath.section)) as! ChecklistTableViewCell
            
            guard let textField = cell.checklistItemField else {
                return
            }
            
            if textField.isEnabled {
                
                // There is an empty ChecklistCell row above, so we need not add one more row
                // We are animating for the animating text field
                
                UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut], animations: {
                    textField.layer.backgroundColor = UIColor(hexString: "#7cb342").cgColor
                }) { (Bool) in
                    UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut], animations: {
                        textField.layer.backgroundColor = UIColor.clear.cgColor
                    }, completion: nil)
                }
                
                return
                
            }
            
            // We are just appedning some garbage data to the Checklist Items as in order to increase the rows upon clicking AddMore button, we need to increase the array otherwise the app will crash
//            checklist.items.append(<#T##newElement: ListItem##ListItem#>)
//            checklistItems.append(ListItem(name: "Some Garbage data", isCompleted: false))
//            tableView.insertRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .bottom)
//
            break
        
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
}

// MARK: - Text Field delegate
extension ChecklistViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let cell = checklistTableView.cellForRow(at: IndexPath(row: textField.tag, section: 0)) as? ChecklistTableViewCell , textField == cell.checklistItemField {
            
            // Setting the text of the textField as the label on the table
            checklist.items[textField.tag].name = (textField.text)!
            
            checklistTableView.reloadRows(at: [IndexPath(row: textField.tag, section: 0)], with: .fade)
            textField.text = ""
            textField.resignFirstResponder()
            textField.isHidden = true
            
            return true
        }
        
        return false
    }

}

// MARK: - Implementing TaskStatus protocol
extension ChecklistViewController: TaskStatusProtocol {
    
    func toggleBetweenTaskStatus(indexPathRow: Int) {
        
        // Reversing the isCompleted value for that task
        checklist.items[indexPathRow].isCompleted.toggle()
        
        // We are sorting the array once again since we have changed the status of the task
        checklist.items.sort(by: { $1.isCompleted })
        
        // Reloading the table to update the data accordingly
        checklistTableView.reloadData()
        
    }
    
}

