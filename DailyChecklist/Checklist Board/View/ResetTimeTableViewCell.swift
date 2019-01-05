//
//  ResetTimeTableViewCell.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 11/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class ResetTimeTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel:UILabel!
    
    // MARK: - Overriding inbuilt Functions
    override func awakeFromNib() {
        super.awakeFromNib()
     
        // Disble gray selection style upon clicking
        selectionStyle = .none
        
    }
    
    override func prepareForReuse() {
        timeLabel.textColor = UIColor(hexString: "#212121")
    }
    
}

