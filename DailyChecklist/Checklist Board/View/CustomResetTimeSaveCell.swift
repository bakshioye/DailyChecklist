//
//  CustomResetTimeSaveCell.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 17/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class CustomResetTimeSaveCell: UITableViewCell {

    @IBOutlet weak var saveForFutureSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        selectionStyle = .none
        
    }
    
    @IBAction func actionForSaveSwitch(_ sender: UISwitch) {
        
    }
    

}
