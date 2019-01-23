//
//  ChecklistSettingsCell.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 10/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class ChecklistSettingsCell: UITableViewCell {

    @IBOutlet weak var cellIcon: UIImageView!
    @IBOutlet weak var settingName: UILabel!
    @IBOutlet weak var settingValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Disable the gray background of cell upon selection
        self.selectionStyle = .none
        
    }



}
