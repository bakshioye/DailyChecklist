//
//  ResetTime.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 12/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import Foundation

struct ResetTimes {
    
    var category: ResetTimeType
    var values: [String]
    
    init(category: ResetTimeType, values: [String]) {
        self.category = category
        self.values = values
    }
    
}
