//
//  DebugConsoleView.swift
//  ABUIKit
//
//  Created by Alexandre barbier on 12/12/15.
//  Copyright © 2015 abarbier. All rights reserved.
//

import UIKit
import Foundation
private let reuseIdentifier = "DebugCell"
public class DebugConsoleView: UIView {
    private var dataSource = [NSAttributedString]()
    private var tableview : UITableView!
    public static var debugView:DebugConsoleView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.tableview = UITableView(frame: self.bounds, style: UITableViewStyle.Grouped)
        self.tableview.backgroundColor = UIColor.clearColor()
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.tableview.separatorStyle = .None
        self.tableview.contentInset = UIEdgeInsetsZero
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        dataSource.append(NSAttributedString(string: "Begin", attributes: [NSForegroundColorAttributeName:UIColor.blueColor(), NSFontAttributeName:UIFont.systemFontOfSize(15)]))
        self.addSubview(tableview)
    }
    
    public convenience init(inView: UIView) {
        self.init(frame: CGRect(origin: CGPoint(x: inView.frame.size.width, y: 0), size: inView.frame.size))
        let swipeHideDebug = UISwipeGestureRecognizer(target: self, action: #selector(DebugConsoleView.hideDebug(_:)))
        swipeHideDebug.direction = .Right
        self.addGestureRecognizer(swipeHideDebug)
        let swipeBorder = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(DebugConsoleView.screenEdge(_:)))
        swipeBorder.edges = UIRectEdge.Right
        inView.addGestureRecognizer(swipeBorder)
        inView.addSubview(self)

    }
    
    func screenEdge(sender: UIScreenEdgePanGestureRecognizer) {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.layer.transform = CATransform3DMakeTranslation(-self.frame.width, 0, 0)
        }
    }
    
    func hideDebug(sender:UISwipeGestureRecognizer) {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.layer.transform = CATransform3DIdentity
        }
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public  func print(message:String) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.dataSource.append(NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName:UIColor.greenColor(),NSFontAttributeName:UIFont.systemFontOfSize(13)]))
            self.tableview.insertRowsAtIndexPaths([NSIndexPath(forRow: self.dataSource.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)
            self.tableview.scrollToRowAtIndexPath(NSIndexPath(forRow: self.dataSource.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        
    }

    public  func warningPrint(message:String) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.dataSource.append(NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName:UIColor.orangeColor(), NSFontAttributeName:UIFont.systemFontOfSize(15)]))
            self.tableview.insertRowsAtIndexPaths([NSIndexPath(forRow: self.dataSource.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)
            self.tableview.scrollToRowAtIndexPath(NSIndexPath(forRow: self.dataSource.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            if (isatty(STDERR_FILENO) == 0) {
                self.errorPrint(String(stderr))
            }
            if (isatty(STDOUT_FILENO) == 0) {
                self.print(String(stderr))
            }

        }
    }
    
    public func errorPrint(message:String) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.dataSource.append(NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName:UIColor.redColor(),NSFontAttributeName:UIFont.systemFontOfSize(20)]))
            self.tableview.insertRowsAtIndexPaths([NSIndexPath(forRow: self.dataSource.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)
            self.tableview.scrollToRowAtIndexPath(NSIndexPath(forRow: self.dataSource.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            if (isatty(STDERR_FILENO) == 0) {
                self.errorPrint(String(stderr))
            }
            if (isatty(STDOUT_FILENO) == 0) {
                self.print(String(stderr))
            }

        }
    }
}

extension DebugConsoleView : UITableViewDataSource, UITableViewDelegate {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Begin"
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier)
        guard let c = cell else {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
            cell!.textLabel?.attributedText = dataSource[indexPath.row]
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.numberOfLines = 0
            cell!.selectionStyle = .None
            return cell!
        }
        c.selectionStyle = .None
        c.backgroundColor = UIColor.clearColor()
        c.textLabel?.numberOfLines = 0
        c.textLabel?.attributedText = dataSource[indexPath.row]
        return c
    }
}
