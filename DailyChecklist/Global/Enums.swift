//
//  Enums.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 13/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

public enum AppStoryboards: String {
    case Dashboard
    case ChecklistBoard
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
}

public enum DatabaseQueryResult {
    case Success
    case Failure
}

public enum CoreDataEntities:String {
    case List
    case CustomResetTime
    case LastResetAtTime
    case ResetTime
}

public enum ChecklistPriority: String {
    case None
    case Low
    case Medium
    case High
}


