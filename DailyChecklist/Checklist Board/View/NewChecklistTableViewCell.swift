//
//  NewChecklistTableViewCell.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 03/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class NewChecklistTableViewCell: UITableViewCell {

    @IBOutlet weak var taskStatus: TaskStatusView!
    @IBOutlet weak var itemNameField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        itemNameField.layer.backgroundColor = UIColor.clear.cgColor
        
        selectionStyle = .none
        
    }

}
