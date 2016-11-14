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
    
    func configure(_ view: DrawableView) {
        switch self {
        case .pen:
            view.brushTool = self
            view.color = view.color.withAlphaComponent(1.0)
            view.lineWidth = 2.0
            break
        case .marker:
            view.brushTool = self
            view.color = view.color.withAlphaComponent(1.0).withAlphaComponent(0.4)
            view.lineWidth = 15.0
            break
        case .eraser:
            break
        case .text:
            view.color = view.color.withAlphaComponent(1.0)
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
    func toolsViewDidSelectTools(_ toolsView:ToolsViewController, tool:Tool)
    func toolsViewChangeUserColor(_ toolsView:ToolsViewController, color:UIColor, colorSeed:CGFloat)
    func toolsViewChangeBrushSize(_ toolsView:ToolsViewController, size:CGFloat)
}

class ToolsViewController: UIViewController {
    @IBOutlet var colorIndicatorView: UIView!
    @IBOutlet var toolsCollectionView: UICollectionView!
    @IBOutlet var sizeSlider: UISlider!
    
    fileprivate var toolsDataSource : [Tool] = [.pen, .marker]
    
    var delegate : ToolsViewDelegate!
    var currentColor:UIColor!
    var selectedTool:Tool!
}

// MARK: - View lifecycle
extension ToolsViewController {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colorIndicatorView.rounded()
        colorIndicatorView.backgroundColor = currentColor
    }
}

extension ToolsViewController:ColorGenerationViewControllerDelegate {
    func didSelectColor(_ color: UIColor, seed: CGFloat) {
        colorIndicatorView.backgroundColor = color
        delegate.toolsViewChangeUserColor(self, color: color, colorSeed: seed)
    }
}

extension ToolsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = StoryboardSegue.Main(rawValue:segue.identifier!) {
            switch identifier {
            case .LoadColorChooser:
                let dest = segue.destination as! ColorGenerationViewController
                dest.delegate = self
                break
            default:
                break
            }
        }
    }
}

// MARK: - CollectionView
extension ToolsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func configureToolsCellForIndexPath(_ cell: UICollectionViewCell, index: IndexPath) {
        let tool = toolsDataSource[(index as NSIndexPath).row]
        if tool == selectedTool {
            toolsCollectionView.selectItem(at: index, animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
        cell.tintColor = tool == selectedTool ? UIColor.draftLinkBlue : UIColor.draftLinkGrey
        cell.backgroundView = UIImageView(image: tool.getIcon()?.withRenderingMode(.alwaysTemplate))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return toolsDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "toolsCell", for: indexPath)
        configureToolsCellForIndexPath(cell, index: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == toolsCollectionView {
            let cell = collectionView.cellForItem(at: indexPath)!
            cell.tintColor = UIColor.draftLinkGrey
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        selectedTool = toolsDataSource[(indexPath as NSIndexPath).row]
        cell.tintColor = UIColor.draftLinkBlue
        delegate.toolsViewDidSelectTools(self, tool:Tool(rawValue: (indexPath as NSIndexPath).row)!)
    }
}

extension ToolsViewController {
    
    @IBAction func sizeToolChanged(_ sender: AnyObject) {
        let slider = sender as! UISlider
        let size = slider.value * 100 / 15
        delegate.toolsViewChangeBrushSize(self, size: CGFloat(size))
    }
    
    @IBAction func onCloseTouch(_ sender: AnyObject) {
        ColorGenerator.instance.reset()
        dismiss(animated: true, completion: nil)
    }
}
