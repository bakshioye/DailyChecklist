//
//  ChecklistSetting.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 11/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import Foundation
import UIKit

struct ChecklistSetting {
    
    var settingIcon: UIImage
    var settingName: ChecklistSettingType
    var settingValue: Any
    
    init(icon:UIImage ,name: ChecklistSettingType, value: Any) {
        settingIcon = icon
        settingName = name
        settingValue = value
    }
}
