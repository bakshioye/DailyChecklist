//
//  CellImageView.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 13/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class CellImageView: UIImageView {

    init(frame: CGRect,image:UIImage) {
        super.init(frame: frame)
        
        self.image = image
        clipsToBounds = true
        contentMode = .scaleAspectFill
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
