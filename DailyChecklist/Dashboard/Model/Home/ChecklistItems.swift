//
//  ChecklistItems.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 15/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import Foundation

struct Checklist {
    var checklistID: UUID
    var name: String
    var creationDate: Date
    var items: [ListItem]
    var priority: ChecklistPriority
    
    init(checklistID: UUID = UUID.init(),priority: ChecklistPriority, name: String, creationDate: Date, items: [ListItem]) {
        self.checklistID = checklistID
        self.priority = priority
        self.name = name
        self.creationDate = creationDate
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


