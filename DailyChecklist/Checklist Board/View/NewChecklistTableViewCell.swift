//
//  NewChecklistTableViewCell.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 03/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class NewChecklistTableViewCell: UITableViewCell {

    // MARK: - Outlet Variables
    @IBOutlet weak var taskStatus: TaskStatusView!
    @IBOutlet weak var itemNameField: UITextField!
    
    // MARK: - Overriding inbuilt functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        itemNameField.layer.backgroundColor = UIColor.clear.cgColor
        
        // Disbale the selection of the text field (gray backround)
        selectionStyle = .none
        
        // Changing the text on the keyword from "Return" to "Done"
        itemNameField.returnKeyType = .done
        
        // Capitalising the first letter of the sentence
        itemNameField.autocapitalizationType = .sentences
        
    }
    
    override func prepareForReuse() {
        
        itemNameField.text = ""
        
    }

}
