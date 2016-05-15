//
//  ToolsViewController.swift
//  Collabboard
//
//  Created by Alexandre barbier on 08/05/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

enum Tool : Int {
    case pen, marker
    
    func getIcon() -> UIImage? {
        switch self {
        case .pen:
            return UIImage(named: "ic_tools_pen")
        case .marker:
            return UIImage(named: "ic_tools_marker")
        }
    }
    
    func getItemIcon() -> UIImage? {
        switch self {
        case .pen:
            return UIImage(named: "ic_pen")
        case .marker:
            return UIImage(named: "ic_marker")
        }
    }
    
    func toString() -> String {
        switch self {
        case .pen:
            return "pen"
        case .marker:
            return "marker"
        }
    }
}

protocol ToolsViewDelegate {
    func toolsViewDidSelectTools(toolsView:ToolsViewController, tool:Tool)
    func toolsViewChangeUserColor(toolsView:ToolsViewController, color:UIColor)
    func toolsViewChangeBrushSize(toolsView:ToolsViewController, size:CGFloat)
}

class ToolsViewController: UIViewController {
    @IBOutlet weak var colorIndicatorView: UIView!
    @IBOutlet weak var toolsCollectionView: UICollectionView!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var sizeSlider: UISlider!
    
    private var toolsDataSource : [Tool] = [.pen, .marker]
    private var colorDataSource:[UIColor] = []
    
    var delegate : ToolsViewDelegate!
    var currentColor:UIColor!
    var selectedTool:Tool!
}

// MARK: - View lifecycle
extension ToolsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        colorIndicatorView.rounded()
        colorIndicatorView.backgroundColor = currentColor
        ColorGenerator.CGSharedInstance.readyBlock = { (ready) in
            self.colorDataSource = Array<UIColor>(count: 12, repeatedValue: UIColor.whiteColor())
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.colorCollectionView.reloadData()
            })
        }
        if let lastOpenedteamProject = Project.getLastOpen() {
            ColorGenerator.CGSharedInstance.team = lastOpenedteamProject.team!
        }
    }
}

// MARK: - CollectionView
extension ToolsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func configureToolsCellForIndexPath(cell: UICollectionViewCell, index: NSIndexPath) {
        let tool = toolsDataSource[index.row]
        if tool == selectedTool {
            toolsCollectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: .None)
            cell.tintColor = UIColor.blueColor()
        }
        else {
            cell.tintColor = UIColor.blackColor()
        }
        cell.backgroundView = UIImageView(image: tool.getIcon()?.imageWithRenderingMode(.AlwaysTemplate))
    }
    
    func configureColorCellForIndexPath(cell: UICollectionViewCell, index: NSIndexPath) {
        cell.rounded(4)
        if colorDataSource[index.row] == UIColor.whiteColor() {
            cell.backgroundColor = ColorGenerator.CGSharedInstance.getNextColor()
            colorDataSource[index.row] = cell.backgroundColor!
        }
        else {
            cell.backgroundColor = colorDataSource[index.row]
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == toolsCollectionView {
            return toolsDataSource.count
        }
        return colorDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == toolsCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("toolsCell", forIndexPath: indexPath)
            configureToolsCellForIndexPath(cell, index: indexPath)
            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorCell", forIndexPath: indexPath)
        configureColorCellForIndexPath(cell, index: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == toolsCollectionView {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)!
            cell.tintColor = UIColor.blackColor()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == toolsCollectionView {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)!
            selectedTool = toolsDataSource[indexPath.row]
            cell.tintColor = UIColor.blueColor()
            delegate.toolsViewDidSelectTools(self, tool:Tool(rawValue: indexPath.row)!)
        }
        else {
            let color = colorDataSource[indexPath.row]
            colorIndicatorView.backgroundColor = color
            delegate.toolsViewChangeUserColor(self, color: color)
        }
    }
}

extension ToolsViewController {
    
    @IBAction func onCloseTouch(sender: AnyObject) {
        ColorGenerator.CGSharedInstance.reset() 
        dismissViewControllerAnimated(true, completion: nil)
    }
}
