//
//  NoChecklistView.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 03/12/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class NoChecklistView: UIView {

    // MARK: - Initailizers
    
    // Called when we create this view programtically
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViewForNoChecklist()
    }
    
    // Called when we create this view via Storyboard
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    func createViewForNoChecklist() {
        
        // Creating a parent view to hold image view and label
        let parentView = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth * 0.9, height: viewHeight * 0.6))
        
        // Centering the parent view inside the main view
        parentView.center.x = self.center.x
        parentView.center.y = self.center.y - self.frame.minY
        

        // Adding the subview to Main view
        addSubview(parentView)
        
        
        // Setting up the image for the view
        let imageViewForNoChecklist = UIImageView(frame: CGRect(x: 0, y: 0, width: parentView.viewHeight * 0.5, height: parentView.viewHeight * 0.5 ))
        
        imageViewForNoChecklist.center = CGPoint(x: parentView.frame.midX - parentView.frame.minX, y: parentView.frame.midY - parentView.frame.minY - parentView.viewHeight * 0.14)
        
        imageViewForNoChecklist.image = #imageLiteral(resourceName: "noChecklistFound")
        
        parentView.addSubview(imageViewForNoChecklist)
        
        // Setting up Label text for the view
        let labelForNoChecklist = UILabel(frame: CGRect(x: 0, y: imageViewForNoChecklist.frame.maxY + 20, width: parentView.viewWidth * 0.9, height: 60))
        
        labelForNoChecklist.center.x = parentView.frame.midX - parentView.frame.minX
        labelForNoChecklist.numberOfLines = 2
        labelForNoChecklist.textAlignment = .center
        labelForNoChecklist.textColor = UIColor(hexString: "#424242")
        labelForNoChecklist.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        
        labelForNoChecklist.text = "No Checklist found. Please create some using button at top right !"

        parentView.addSubview(labelForNoChecklist)
        
    }
    
}
