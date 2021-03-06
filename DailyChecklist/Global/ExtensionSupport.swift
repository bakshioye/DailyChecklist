//
//  ExtensionSupport.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 13/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

extension UIView {
    
    var viewWidth: CGFloat {
        return self.frame.size.width
    }
    
    var viewHeight: CGFloat {
        return self.frame.size.height
    }
        
    func anchorToTop(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {
            
        anchorWithConstantsToTop(top: top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
        
    func anchorWithConstantsToTop(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {
            
        translatesAutoresizingMaskIntoConstraints = false
            
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
            
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant).isActive = true
        }
            
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: leftConstant).isActive = true
        }
            
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -rightConstant).isActive = true
        }
            
    }

}

extension NSObject {
    
    func findIndexOf<T: Equatable>(_ element: T,in arrayOfElements: [T]) -> Int {
        
        for (index,currentValue) in arrayOfElements.enumerated() {
            if element == currentValue {
                return index
            }
        }
        
        return -1
        
    }
    
}

extension Int {
    
    var isEven: Bool {
        return self % 2 == 0
    }
    
}

extension UIColor {
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
}

extension UIViewController {
    
    func presentErrorAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc fileprivate func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

// MARK: - This contains all the functions that are common to all the View Controllers
extension UIViewController {
    
    /**
        Converts the *Time Domain* provided to a *String* that can be used to display on cells and other places
     
        - Parameter timeInDomain: Time in *TimeDomain*
     
        - Returns: A string representation of *TimeDomain*
     
        - Note: It converts *(1,2,3,4,5)* a.k.a *TimeDomain* to *5 months 4 weeks 3 days 2 hours 1 minute* a.k.a *String Representation*
    */
    func convertTimeDomainToString(_ timeInDomain:TimeDomain) -> String {
        
        let monthsString = timeInDomain.month != 0 ? (timeInDomain.month > 1 ? "\(timeInDomain.month) months " : "\(timeInDomain.month) month " ) : ""
        
        let weeksString = timeInDomain.week != 0 ? (timeInDomain.week > 1 ? "\(timeInDomain.week) weeks " : "\(timeInDomain.week) week " ) : ""
        
        let daysString = timeInDomain.day != 0 ? (timeInDomain.day > 1 ? "\(timeInDomain.day) days " : "\(timeInDomain.day) day " ) : ""
        
        let hoursString = timeInDomain.hour != 0 ? (timeInDomain.hour > 1 ? "\(timeInDomain.hour) hours " : "\(timeInDomain.hour) hour " ) : ""
        
        let minuteString = timeInDomain.minute != 0 ? (timeInDomain.minute > 1 ? "\(timeInDomain.minute) minutes " : "\(timeInDomain.minute) minute " ) : ""
        
        return monthsString+weeksString+daysString+hoursString+minuteString
        
    }
    
    /**
     Converts the *String* provided to a *TimeDomain* that can be passed around
     
     - Parameter aString: Time in *String*
     
     - Returns: A *TimeDomain* representation of time in *String*
     
     - Note: It converts *5 months 4 weeks 3 days 2 hours 1 minute* a.k.a *String Representation* to *(1,2,3,4,5)* a.k.a *TimeDomain*
     
     - Requires: The *time unit* inside the string should be plural and not singular like **months** insted of **month**
     */
    func convertStringToTimeDomain(_ aString: String) -> TimeDomain {
        
        // Splitting the string based on space
        var arrayOfTimeComponents = aString.components(separatedBy: " ")
        
        // Removing the trailing and leading spaces from the string
        if arrayOfTimeComponents.last == "" {
            arrayOfTimeComponents.removeLast()
        }
        if arrayOfTimeComponents.first == "" {
            arrayOfTimeComponents.removeFirst()
        }
        
        // Since each even positon(start from 0) of the array will have values for time domain (like 1,3) and each odd postion will have the unit of the time domain (day,minute)
        
        /**
            This will hold the time domains as in the form of dictionary like "months:4"
         
            - Note: We have used string as the *key* as we will only have one *time unit* like months in our string but the values can be repetitive
        */
        var timeDomainDict = Dictionary<String,Int>()
        
        for currentIndex in stride(from: 0, to: arrayOfTimeComponents.count, by: 2) {
            timeDomainDict[arrayOfTimeComponents[currentIndex+1]] = Int(arrayOfTimeComponents[currentIndex])
        }
        
        // Making the TimeDomain Object out of the dictionary
        // If any of the time unit is nil, we return 0 in place of it
        return (timeDomainDict["minutes"] ?? timeDomainDict["minute"] ?? 0 ,
                timeDomainDict["hours"] ?? timeDomainDict["hour"] ?? 0,
                timeDomainDict["days"] ?? timeDomainDict["day"] ?? 0,
                timeDomainDict["weeks"] ?? timeDomainDict["week"] ?? 0,
                timeDomainDict["months"] ?? timeDomainDict["month"] ?? 0)
        
    }
    
    /**
        Creates an array of list items for a checklist from the string provided
     
        - Parameter listItemsInString: List of items as *String*
     
        - Returns: An array of list of items as *ListItem*
    */
    func convertStringToListItems(listItemsInString: String) -> [ListItem] {
        
        var listItemArray = [ListItem]()
        
        let arrayOfItems = listItemsInString.components(separatedBy: "\\i")
        
        for currentItem in arrayOfItems {
            
            // 0 position will have name of the item and 1 positon will have the status of that item
            let tempArray = currentItem.components(separatedBy: "\\b")
            
            listItemArray.append(ListItem(name: tempArray[0], isCompleted: Bool(tempArray[1])!))
        }
        
        return listItemArray
    }
    
    /**
     Here we convert **List of items** into a string in which items and its completion status will be seperated by some characters
     
     - Parameter items: An array of List Item of a checklist
     
     - Returns: A string made up of List Items and its completion status combined as one and seperated by some identifiers
     */
    func convertListItemsToString(items: [ListItem]) -> String {
        
        /**
         \\(Double back slash is used to avoid escape characters)
         \i -> seperator between items
         \b -> seperator between item name and it's boolean value
         **/
        
        var arrayOfItems = Array<String>()
        
        for currentItem in items {
            arrayOfItems.append("\(currentItem.name)\\b\(currentItem.isCompleted)")
        }
        
        return arrayOfItems.joined(separator: "\\i")
        
    }
    
    /**
        This function adds a blur effect to the *Main View* of the view controller (i.e. self.view)
     
        - Parameter shouldBeAdded: *true* in case the blur effect should be added, *false* in case blur effect should be removed
     
    */
    func blurBackgroundEffect(shouldBeAdded: Bool) {
        
        switch shouldBeAdded {
            
        case true:
            // Creating a blur effect
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
            
            // Main Blur Effect View
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.frame
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // We are providing this tag so that we can remove this Blur View later
            blurEffectView.tag = 1001
            
            view.addSubview(blurEffectView)
            
        case false:
            
            if let viewWithTag1001 = self.view.viewWithTag(1001) {
                viewWithTag1001.removeFromSuperview()
            }
            
        }
    
    }

}

