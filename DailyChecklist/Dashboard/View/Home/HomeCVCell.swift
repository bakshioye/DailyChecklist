//
//  HomeCVCell.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 15/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class HomeCVCell: UICollectionViewCell {

    @IBOutlet weak var someTitleLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        
        
    }

}
