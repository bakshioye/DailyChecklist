//
//  PrioritySelectionView.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 22/01/19.
//  Copyright © 2019 Shubham Bakshi. All rights reserved.
//

import UIKit

class PrioritySelectionView: UIView {

    // MARK: - Variables to be used
    
    /// The delegate object to be used to trasnfer data to another view controller
    var transferDataDelegate: TransferData?
    
    /// This will define whether priority is already set
    var priorityAlreadySet: ChecklistPriority
    
    let arrayOfPriorities = ["None","Low","Medium","High"]
    
    // MARK: - Overriding inbuilt functions
    
    // This constructor will be called when we are creating view programatically
    init(frame: CGRect, priorityAlreadySet: ChecklistPriority) {
        self.priorityAlreadySet = priorityAlreadySet
        super.init(frame: frame)
    
        setupSelectionView()
    }
    
    // This constructor will be called when we are creating view via Storyboard
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Helper Functions
extension PrioritySelectionView {
    
    fileprivate func setupSelectionView() {
        
        // Creating a stack view that will contain all the labels for the priority
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.viewWidth, height: self.viewHeight))
        
        // Setting layout for Stack View
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        
        // Here we are creating four labels for all the cases of the priority
        for index in 0...3 {
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: stackView.viewWidth, height: 40))
            
            label.text = arrayOfPriorities[index]
            label.layer.cornerRadius = 10.0
            label.clipsToBounds = true
            
            // Checking if there already exists a priority for checklist and assigning a different background color to it
            label.backgroundColor = arrayOfPriorities[index] == priorityAlreadySet.rawValue ? UIColor(hexString: "#e6ee9c") : UIColor.clear
            
            // Assigning an index so that i can identify which text field was tapped
            label.tag = index
            
            label.textColor = UIColor(hexString: "#424242")
            label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            label.textAlignment = .center

            // Adding a tap gesture recognizer to each text field
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandlerForTextField(_ :)))
            label.addGestureRecognizer(tapGestureRecognizer)
            label.isUserInteractionEnabled = true
            
            stackView.addArrangedSubview(label)
        }
        
    }
    
    @objc func tapHandlerForTextField(_ sender: UITapGestureRecognizer) {
        transferDataDelegate?.prioritySelected(ChecklistPriority(rawValue: arrayOfPriorities[sender.view!.tag]) ?? .None)
    }
    
}
