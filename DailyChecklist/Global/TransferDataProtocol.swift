//
//  TransferDataProtocol.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 12/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import Foundation

protocol TransferData {
    func updateResetTime(newResetTime: TimeDomain)
    func customTimeSelected(inSeconds: TimeInterval)
}

extension TransferData {
    func updateResetTime(newResetTime: TimeDomain) { }
    func customTimeSelected(inSeconds: TimeInterval) { }
}
