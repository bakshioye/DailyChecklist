//
//  HomeCVCell.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 15/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class HomeCVCell: UICollectionViewCell {

    // MARK: - Outlet Variables
    @IBOutlet weak var someTitleLable: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var checklistProgressView: UIView!
    
    // MARK: - Local variables to be used
    var tasksCompleted: CGFloat!
    var totalTasks: CGFloat!
    
    // MARK: - Overriding inbuilt functions
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        
        /// Just testing these values, replace them with values from Core Data
        tasksCompleted = 5.0
        totalTasks = 10.0
        
        percentageLabel.textColor = UIColor(hexString: "#616161")
        
        setupChecklistProgress()
        
//        checklistProgressView.layer.borderWidth = 2.0
        
    }
    
}

// MARK: - Helper functions
extension HomeCVCell {
    
    fileprivate func setupChecklistProgress() {
        
        // Adding the circular Progress View
        let radius = checklistProgressView.viewWidth / 3
        
        let circularPath = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: 0, endAngle: CGFloat(2 * CFloat.pi) , clockwise: true)

        // Creating layer for background
        createCircularLayer(circularPath: circularPath, circularPathRadius: radius, strokeColor: UIColor(hexString: "#e0e0e0").cgColor, strokeEnd: 1)
        
        // Creating layer for foreground
        createCircularLayer(circularPath: circularPath, circularPathRadius: radius, strokeColor: UIColor(hexString: "#66bb6a").cgColor, strokeEnd: tasksCompleted/totalTasks)
        
        // Setting text for the label
        let labelText = "\(Int(tasksCompleted))/\(Int(totalTasks))"
        
        percentageLabel.text = "\(labelText)\n(\(Int(tasksCompleted/totalTasks * 100))%)"
        
    }
    
    fileprivate func createCircularLayer(circularPath: UIBezierPath,circularPathRadius:CGFloat,strokeColor:CGColor,strokeEnd:CGFloat) {
        
        let circularLayer = CAShapeLayer()
        
        circularLayer.path = circularPath.cgPath
        
        circularLayer.strokeColor = strokeColor
        circularLayer.lineWidth = 10
        circularLayer.fillColor = UIColor.clear.cgColor
        circularLayer.lineCap = CAShapeLayerLineCap.round
        circularLayer.position = CGPoint(x: checklistProgressView.center.x , y: checklistProgressView.center.y - circularPathRadius/2)
        circularLayer.strokeStart = 0
        circularLayer.strokeEnd = strokeEnd
        circularLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        layer.addSublayer(circularLayer)
        
    }

}
