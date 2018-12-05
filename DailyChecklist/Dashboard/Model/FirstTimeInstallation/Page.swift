//
//  Page.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 13/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

struct Page {
    
    let image: UIImage
    let title: String
    let message: String
    
    init(image:UIImage,title:String,message:String) {
        self.image = image
        self.title = title
        self.message = message
    }
    
}
