//
//  HomeCollectionView.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 14/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class HomeCollectionView: UICollectionView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.minimumLineSpacing = 5
//            layout.minimumInteritemSpacing = 5
            layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
        
    }

}
