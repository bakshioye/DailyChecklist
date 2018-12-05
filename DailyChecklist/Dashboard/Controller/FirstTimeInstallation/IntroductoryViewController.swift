//
//  IntroductoryViewController.swift
//  DailyChecklist
//
//  Created by Shubham Bakshi on 13/11/18.
//  Copyright © 2018 Shubham Bakshi. All rights reserved.
//

import UIKit

class IntroductoryViewController: UIViewController {

    // MARK: - Outlet Variables
    
    @IBOutlet weak var paginationCollectionView: PaginationCollectionView!
    
    // MARK: - Custom made variables
    
    var pages = [Page]()
    
    // MARK: - Overriding inbuilt functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
      return
        
      pages.append(Page(image: #imageLiteral(resourceName: "image1"), title: "First Page", message: "This is the first page"))
      pages.append(Page(image: #imageLiteral(resourceName: "image2"), title: "Second Page", message: "This is the Second page"))
      pages.append(Page(image: #imageLiteral(resourceName: "image1"), title: "Third Page", message: "This is the Third page"))
      pages.append(Page(image: #imageLiteral(resourceName: "image2"), title: "Fourth Page", message: "This is the Fourth page"))
        
        
       paginationCollectionView.dataSource = self
       paginationCollectionView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "homeNavigationController") as! HomeNavigationController
        
        self.present(homeVC, animated: false, completion: nil)
    }

}

// MARK: - CollectionView Data Source

extension IntroductoryViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PAGINATION_CELL_ID, for: indexPath) as! PaginationCell
        
        cell.pageData = pages[indexPath.item]
        cell.setupPage()
        
        return cell
        
    }
    
}

// MARK: - CollectionView Delegate Flow Layout

extension IntroductoryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.viewWidth, height: collectionView.viewHeight)
    }
    
}


