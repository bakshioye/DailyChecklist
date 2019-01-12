//
//  ArrayWithLabel.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 17/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import Foundation

public struct ArrayWithLabel<N,V> { // N -> Name        V -> Values
    
    var name: N
    var values: [V]
    
    init(name: N,values: [V]) {
        self.name = name
        self.values = values
    }
    
}
