//
//  PaginationCollectionView.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 13/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class PaginationCollectionView: UICollectionView {
    
    /// This will be called when WE ARE CREATING THE COLLECTION VIEW PROGRAMAICALLY !!!!
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    /// This will be called when WE ARE CREATING THE COLLECTION VIEW via STORYBOARD !!!!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        

        register(PaginationCell.self, forCellWithReuseIdentifier: PAGINATION_CELL_ID)
        isPagingEnabled = true
        // Changing the scroll direction of the CollectionView
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
    }
    
}
