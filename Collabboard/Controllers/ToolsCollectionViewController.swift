//
//  ToolsCollectionViewController.swift
//  Collabboard
//
//  Created by Alexandre barbier on 18/02/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let colorReuseIdentifier = "colorCell"

enum Tool : Int {
    case pen = 0, marker = 1
}

protocol ToolsViewDelegate {
    func didSelectTools(popover:ToolsCollectionViewController,tool:Tool)
    func changeUserColor(popover:ToolsCollectionViewController,color:UIColor)
    func changeBrushSize(popover:ToolsCollectionViewController,size:CGFloat)
}

class ToolsCollectionViewController: UICollectionViewController, UIPopoverPresentationControllerDelegate {
    
    private var toolsDataSource = ["pen", "marker"]
    private var colorsDataSource : [UIColor] = []
    private var sizesDataSource = ["pen"]
    var team : Team!
    var delegate : ToolsViewDelegate?
}

// MARK: - View lifecycle
extension ToolsCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "separator")
        self.preferredContentSize = CGSize(width: UIScreen.mainScreen().bounds.width - 16, height: 159)
        ColorGenerator.CGSharedInstance.readyBlock = { (ready) in
            self.colorsDataSource = Array<UIColor>(count: 12, repeatedValue: UIColor.whiteColor())
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.collectionView?.reloadData()
            })
        }
        if let lastOpenedteamProject = Project.getLastOpen() {
            ColorGenerator.CGSharedInstance.team = lastOpenedteamProject.team!
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
}

// MARK: - CollectionView
extension ToolsCollectionViewController {
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
            number = sizesDataSource.count
            break
        case 1 :
            number = colorsDataSource.count
            break
            
        case 2 :
            number = toolsDataSource.count
            break
            
        default:
            break
        }
        return number
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = indexPath.section == 1 ? collectionView.dequeueReusableCellWithReuseIdentifier(colorReuseIdentifier, forIndexPath: indexPath) : collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0 :
            cell.backgroundView = UIImageView(image: UIImage(named: sizesDataSource[indexPath.row]))
            break
        case 1 :
            var frame = cell.bounds
            frame.size.width = frame.width - 16
            frame.size.height = frame.height - 16
            frame.origin = CGPoint(x: 8, y: 8)
            let v = UIView(frame: frame)
            v.circle()
            if colorsDataSource[indexPath.row] == UIColor.whiteColor() {
                v.backgroundColor = ColorGenerator.CGSharedInstance.getNextColor()
                colorsDataSource[indexPath.row] = v.backgroundColor!
            }
            else {
                v.backgroundColor = colorsDataSource[indexPath.row]
            }
            
            cell.addSubview(v)
            break
            
        case 2 :
            cell.backgroundView = UIImageView(image: UIImage(named: toolsDataSource[indexPath.row]))
            break
            
        default:
            break
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0 :
            
            break
        case 1 :
            
            break
            
        case 2 :
            if let delegate = self.delegate {
                delegate.didSelectTools(self, tool:Tool(rawValue: indexPath.row)!)
            }
            break
            
        default:
            break
        }
    }
}
