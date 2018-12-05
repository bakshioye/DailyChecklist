//
//  ChecklistItems.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 15/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import Foundation

struct Checklist {
    var name: String
    var creationDate: Date
    var resetTime: Date?
    var items: [ListItem]
    
    init(name: String, creationDate: Date, resetTime: Date?, items: [ListItem]) {
        self.name = name
        self.creationDate = creationDate
        self.resetTime = resetTime
        self.items = items        
    }
    
}

struct ListItem {
    var name: String
    var isCompleted: Bool
    
    init(name: String, isCompleted: Bool) {
        self.name = name
        self.isCompleted = isCompleted
    }
}


