//
//  ToolsCollectionViewController.swift
//  Collabboard
//
//  Created by Alexandre barbier on 18/02/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ToolsCollectionViewController: UICollectionViewController, UIPopoverPresentationControllerDelegate {
    

    private var toolsDataSource = ["pen", "marker","marker","marker","marker","marker","marker","marker","marker","marker","marker"]
    private var colorsDataSource = ["pen"]
    private var sizesDataSource = ["pen"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "separator")
        self.preferredContentSize = CGSize(width: UIScreen.mainScreen().bounds.width - 16, height: 159)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let reuseView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "separator", forIndexPath: indexPath)
        if indexPath.section == 2 {
            reuseView.backgroundColor = UIColor.clearColor()
        }
        return reuseView
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var number = 0
        switch section {
        case 0 :
            number = self.sizesDataSource.count
            break
        case 1 :
            number = self.colorsDataSource.count
            break
            
        case 2 :
            number = self.toolsDataSource.count
            break
            
        default:
            break
        }
        return number
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        // Configure the cell
        switch indexPath.section {
        case 0 :
           cell.backgroundView = UIImageView(image: UIImage(named: self.sizesDataSource[indexPath.row]))
            break
        case 1 :
           cell.backgroundView = UIImageView(image: UIImage(named: self.colorsDataSource[indexPath.row]))
            break
            
        case 2 :
            cell.backgroundView = UIImageView(image: UIImage(named: self.toolsDataSource[indexPath.row]))
            break
            
        default:
            break
        }

        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0 :

            break
        case 1 :

            break
            
        case 2 :

            break
            
        default:
            break
        }

    }
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
