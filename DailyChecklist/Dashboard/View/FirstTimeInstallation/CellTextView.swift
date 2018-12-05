//
//  CellTextView.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 13/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class CellTextView: UITextView {

    init(frame: CGRect,text:String) {
        super.init(frame: frame, textContainer: nil)
        
        self.text = text
        isEditable = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
