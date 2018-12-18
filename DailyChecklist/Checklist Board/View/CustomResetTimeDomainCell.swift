//
//  CustomResetTimeDomainCell.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 17/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class CustomResetTimeDomainCell: UITableViewCell {

    @IBOutlet weak var timeDomainNameLabel: UILabel!
    @IBOutlet weak var timeDomainValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
    }



}
