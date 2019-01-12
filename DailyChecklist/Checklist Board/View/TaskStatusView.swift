//
//  TaskStatusView.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 30/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

fileprivate enum TaskStatus: String {
    case Completed = "Completed"
    case NotCompleted = "Not Completed"
}

@IBDesignable class TaskStatusView: UIView {

    @IBInspectable var taskCompleted: Bool = false {
        
        didSet {
            
            // Drawing the outer circle
            let outerCirclePath = UIBezierPath(arcCenter: CGPoint(x: 15,y: 15), radius: CGFloat(10), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
            
            let outerCircleShapeLayer = CAShapeLayer()
            outerCircleShapeLayer.path = outerCirclePath.cgPath
            
            outerCircleShapeLayer.fillColor = UIColor.clear.cgColor
            
            outerCircleShapeLayer.strokeColor = taskCompleted ? UIColor(hexString: "#d4e157").cgColor : UIColor(hexString: "#e0e0e0").cgColor
            
            outerCircleShapeLayer.lineWidth = 3.0
            
            layer.addSublayer(outerCircleShapeLayer)
            
            // Drawing the inner circle
            let innerCirclePath = UIBezierPath(arcCenter: CGPoint(x: 15,y: 15), radius: CGFloat(7), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
            
            let innerCircleShapeLayer = CAShapeLayer()
            innerCircleShapeLayer.path = innerCirclePath.cgPath
            
            innerCircleShapeLayer.fillColor = taskCompleted ? UIColor(hexString: "#d4e157").cgColor : UIColor(hexString: "#e0e0e0").cgColor

            layer.addSublayer(innerCircleShapeLayer)
            
        }
        
    }
    
}
