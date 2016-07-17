//
//  ToolsViewController.swift
//  Collabboard
//
//  Created by Alexandre barbier on 08/05/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

enum Tool : Int {
    case pen, marker, eraser, text
    
    func getIcon() -> UIImage? {
        switch self {
        case .pen:
            return UIImage.Asset.Ic_tools_pen.image
        case .marker:
            return UIImage.Asset.Ic_tools_marker.image
        case .eraser, .text:
            return nil
            
        }
    }
    
    func getItemIcon() -> UIImage? {
        switch self {
        case .pen:
            return UIImage.Asset.Ic_pen.image
        case .marker:
            return UIImage.Asset.Ic_marker.image
        case .eraser, .text:
            return nil
        }
    }
    
    func configure(view: DrawableView) {
        switch self {
        case .pen:
            view.brushTool = self
            view.color = view.color.colorWithAlphaComponent(1.0)
            view.lineWidth = 2.0
            break
        case .marker:
            view.brushTool = self
            view.color = view.color.colorWithAlphaComponent(1.0).colorWithAlphaComponent(0.4)
            view.lineWidth = 15.0
            break
        case .eraser:
            break
        case .text:
            view.color = view.color.colorWithAlphaComponent(1.0)
            break
        }
    }
    
    func toString() -> String {
        switch self {
        case .pen:
            return "pen"
        case .marker:
            return "marker"
        case .eraser:
            return "eraser"
        case .text:
            return "text"
        }
    }
}

protocol ToolsViewDelegate {
    func toolsViewDidSelectTools(toolsView:ToolsViewController, tool:Tool)
    func toolsViewChangeUserColor(toolsView:ToolsViewController, color:UIColor, colorSeed:CGFloat)
    func toolsViewChangeBrushSize(toolsView:ToolsViewController, size:CGFloat)
}

class ToolsViewController: UIViewController {
    @IBOutlet var colorIndicatorView: UIView!
    @IBOutlet var toolsCollectionView: UICollectionView!
    @IBOutlet var sizeSlider: UISlider!
    
    private var toolsDataSource : [Tool] = [.pen, .marker]
    
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
    }
}

extension ToolsViewController:ColorGenerationViewControllerDelegate {
    func didSelectColor(color: UIColor, seed: CGFloat) {
        colorIndicatorView.backgroundColor = color
        delegate.toolsViewChangeUserColor(self, color: color, colorSeed: seed)
    }
}

extension ToolsViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == StoryboardSegue.Main.LoadColorChooser.rawValue {
            let dest = segue.destinationViewController as! ColorGenerationViewController
            dest.delegate = self
            
        }
    }
}

// MARK: - CollectionView
extension ToolsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func configureToolsCellForIndexPath(cell: UICollectionViewCell, index: NSIndexPath) {
        let tool = toolsDataSource[index.row]
        if tool == selectedTool {
            toolsCollectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: .None)
            cell.tintColor = UIColor.draftLinkBlue()
        }
        else {
            cell.tintColor = UIColor.draftLinkGrey()
        }
        cell.backgroundView = UIImageView(image: tool.getIcon()?.imageWithRenderingMode(.AlwaysTemplate))
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return toolsDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("toolsCell", forIndexPath: indexPath)
        configureToolsCellForIndexPath(cell, index: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == toolsCollectionView {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)!
            cell.tintColor = UIColor.draftLinkGrey()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)!
        selectedTool = toolsDataSource[indexPath.row]
        cell.tintColor = UIColor.draftLinkBlue()
        delegate.toolsViewDidSelectTools(self, tool:Tool(rawValue: indexPath.row)!)
    }
}

extension ToolsViewController {
    
    @IBAction func sizeToolChanged(sender: AnyObject) {
        let slider = sender as! UISlider
        let size = slider.value * 100 / 15
        delegate.toolsViewChangeBrushSize(self, size: CGFloat(size))
    }
    @IBAction func onCloseTouch(sender: AnyObject) {
        ColorGenerator.CGSharedInstance.reset()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
