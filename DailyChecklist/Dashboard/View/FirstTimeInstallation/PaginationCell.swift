//
//  PaginationCell.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 13/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class PaginationCell: UICollectionViewCell {
    
    // MARK: - Custom variables
    
    var pageData:Page?

}

// MARK: - Helper Functions

extension PaginationCell {
    
    func setupPage() {
        
        let imageView = CellImageView(frame: .zero, image: pageData!.image)
        addSubview(imageView)
        
        let textView = CellTextView(frame: .zero, text: pageData!.message)
        addSubview(textView)
        
        imageView.anchorToTop(top: topAnchor, left: leftAnchor, bottom: textView.topAnchor, right: rightAnchor)
        
        textView.anchorToTop(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        textView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
    }
    
}
