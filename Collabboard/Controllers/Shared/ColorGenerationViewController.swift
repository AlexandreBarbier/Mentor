//
//  ColorGenerationViewController.swift
//  Mentor
//
//  Created by Alexandre barbier on 11/01/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {

    @IBOutlet var quoteImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        quoteImageView.image = quoteImageView.image?.withRenderingMode(.alwaysTemplate)
        quoteImageView.tintColor  = UIColor.white
        quoteImageView.isHidden = true
    }
}

protocol ColorGenerationViewControllerDelegate: class {
    func didSelectColor(_ color: UIColor, seed: CGFloat)
}

class ColorGenerationViewController: UIViewController {

    @IBOutlet var colorCollectionView: UICollectionView!

    fileprivate var colorDataSource:[(color: UIColor, colorSeed: CGFloat)] = []
    fileprivate var selectedIndex = -1
    weak var delegate: ColorGenerationViewControllerDelegate?
    var loadFromNil = false
}

// MARK: - View lifecycle
extension ColorGenerationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ColorGenerator.instance.readyBlock = { (ready) in
            self.colorDataSource = [(color: UIColor, colorSeed: CGFloat)](repeating: (UIColor.white, 0), count: 12)
            OperationQueue.main.addOperation({ () -> Void in
                self.colorCollectionView.reloadData()
            })
        }
        if !loadFromNil {
            if let lastOpenedteamProject = Project.getLastOpen() {
                ColorGenerator.instance.team = lastOpenedteamProject.team!
            }
        } else {
            ColorGenerator.instance.currentSeed = 0
            ColorGenerator.instance.readyBlock!(true)
        }
    }
}

// MARK: - CollectionView
extension ColorGenerationViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func configureColorCellForIndexPath(_ cell: UICollectionViewCell, index: IndexPath) {
        cell.rounded(4)
        if colorDataSource[(index as NSIndexPath).row].color == UIColor.white {
            colorDataSource[(index as NSIndexPath).row] = ColorGenerator.instance.getNextColor()!
            cell.backgroundColor = colorDataSource[(index as NSIndexPath).row].color
        } else {
            cell.backgroundColor = colorDataSource[(index as NSIndexPath).row].color
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorDataSource.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? ColorCell
        configureColorCellForIndexPath(cell!, index: indexPath)
        cell?.quoteImageView.isHidden = selectedIndex != (indexPath as NSIndexPath).row
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.didSelectColor(colorDataSource[(indexPath as NSIndexPath).row].color,
                                    seed:colorDataSource[(indexPath as NSIndexPath).row].colorSeed)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = delegate {
            selectedIndex = (indexPath as NSIndexPath).row
            colorCollectionView.reloadData()
            delegate.didSelectColor(colorDataSource[(indexPath as NSIndexPath).row].color,
                                    seed:colorDataSource[(indexPath as NSIndexPath).row].colorSeed)
        }
    }
}
