//
//  ChecklistTableViewCell.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 16/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

protocol TaskStatusProtocol {
    func toggleBetweenTaskStatus(indexPathRow: Int)
}

class ChecklistTableViewCell: UITableViewCell {

    // MARK: - Outlet variables
    @IBOutlet weak var taskStatus: TaskStatusView!
    @IBOutlet weak var checklistItemLabel: UILabel!
    @IBOutlet weak var checklistItemField: UITextField!
    
    // MARK: - Variables to be used
    var taskStatusDelegate: TaskStatusProtocol?

    // MARK: - Overiding inbuilt functions
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // So that when the user selects the tableView cell, the cell will not be displayed as gray
        selectionStyle = .none
        
        // Hiding the textField initially as the user will only want to see the label and not edit the item name
        checklistItemField.isHidden = true
        
        // Changing the text of the keyboard's return button to "Done"
        checklistItemField.returnKeyType = .done
        
        // Adding a Tap Gesture Recognizer so that we can differentiate when the user tapped on taskStatus and when he tapped on Item Label
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapForTaskStatus(_:)))
        taskStatus.isUserInteractionEnabled = true
        taskStatus.addGestureRecognizer(tapGestureRecognizer)
        
        /****
            NOTE - When the user taps on taskStatus , we are marking the item as completed or notCompleted and when the user taps on itemLabel ( via didSelectRowAt() ), we are changing the item's name
        ****/
        
        checklistItemField.addTarget(self, action: #selector(hideTextFieldOnLosingFocus(_:)), for: .allEditingEvents)
        
    }

}

// MARK: - Helper Functions
extension ChecklistTableViewCell {
    
    @objc fileprivate func handleTapForTaskStatus(_ gesture: UITapGestureRecognizer) {
        taskStatusDelegate?.toggleBetweenTaskStatus(indexPathRow: self.tag)        
    }
    
    @objc fileprivate func hideTextFieldOnLosingFocus(_ textField: UITextField) {
        
        // When there is already one textfield enabled for one item and the user clicks anywhere else and that textfield loses focus, then we make that textfield disappear
        if !textField.isFirstResponder {
            textField.isHidden = true
        }
        
    }
    
}


