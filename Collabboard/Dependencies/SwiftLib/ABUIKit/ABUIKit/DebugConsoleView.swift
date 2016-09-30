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
open class DebugConsoleView: UIView {
    fileprivate var dataSource = [NSAttributedString]()
    fileprivate var tableview : UITableView!
    open static var debugView:DebugConsoleView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.tableview = UITableView(frame: self.bounds, style: UITableViewStyle.grouped)
        self.tableview.backgroundColor = UIColor.clear
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.tableview.separatorStyle = .none
        self.tableview.contentInset = UIEdgeInsets.zero
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        dataSource.append(NSAttributedString(string: "Begin", attributes: [NSForegroundColorAttributeName:UIColor.blue, NSFontAttributeName:UIFont.systemFont(ofSize: 15)]))
        self.addSubview(tableview)
    }
    
    public convenience init(inView: UIView) {
        self.init(frame: CGRect(origin: CGPoint(x: inView.frame.size.width, y: 0), size: inView.frame.size))
        let swipeHideDebug = UISwipeGestureRecognizer(target: self, action: #selector(DebugConsoleView.hideDebug(_:)))
        swipeHideDebug.direction = .right
        self.addGestureRecognizer(swipeHideDebug)
        let swipeBorder = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(DebugConsoleView.screenEdge(_:)))
        swipeBorder.edges = UIRectEdge.right
        inView.addGestureRecognizer(swipeBorder)
        inView.addSubview(self)

    }
    
    func screenEdge(_ sender: UIScreenEdgePanGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.layer.transform = CATransform3DMakeTranslation(-self.frame.width, 0, 0)
        }) 
    }
    
    func hideDebug(_ sender:UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.layer.transform = CATransform3DIdentity
        }) 
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open  func print(_ message:String) {
        
        OperationQueue.main.addOperation { () -> Void in
            self.dataSource.append(NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName:UIColor.green,NSFontAttributeName:UIFont.systemFont(ofSize: 13)]))
            self.tableview.insertRows(at: [IndexPath(row: self.dataSource.count - 1, section: 0)], with: UITableViewRowAnimation.right)
            self.tableview.scrollToRow(at: IndexPath(row: self.dataSource.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        }
        
    }

    open  func warningPrint(_ message:String) {
        
        OperationQueue.main.addOperation { () -> Void in
            self.dataSource.append(NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName:UIColor.orange, NSFontAttributeName:UIFont.systemFont(ofSize: 15)]))
            self.tableview.insertRows(at: [IndexPath(row: self.dataSource.count - 1, section: 0)], with: UITableViewRowAnimation.right)
            self.tableview.scrollToRow(at: IndexPath(row: self.dataSource.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
            if (isatty(STDERR_FILENO) == 0) {
                self.errorPrint(String(describing: stderr))
            }
            if (isatty(STDOUT_FILENO) == 0) {
                self.print(String(describing: stderr))
            }

        }
    }
    
    open func errorPrint(_ message:String) {
        
        OperationQueue.main.addOperation { () -> Void in
            self.dataSource.append(NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName:UIColor.red,NSFontAttributeName:UIFont.systemFont(ofSize: 20)]))
            self.tableview.insertRows(at: [IndexPath(row: self.dataSource.count - 1, section: 0)], with: UITableViewRowAnimation.right)
            self.tableview.scrollToRow(at: IndexPath(row: self.dataSource.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
            if (isatty(STDERR_FILENO) == 0) {
                self.errorPrint(String(describing: stderr))
            }
            if (isatty(STDOUT_FILENO) == 0) {
                self.print(String(describing: stderr))
            }

        }
    }
}

extension DebugConsoleView : UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Begin"
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        guard let c = cell else {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
            cell!.textLabel?.attributedText = dataSource[(indexPath as NSIndexPath).row]
            cell!.backgroundColor = UIColor.clear
            cell!.textLabel?.numberOfLines = 0
            cell!.selectionStyle = .none
            return cell!
        }
        c.selectionStyle = .none
        c.backgroundColor = UIColor.clear
        c.textLabel?.numberOfLines = 0
        c.textLabel?.attributedText = dataSource[(indexPath as NSIndexPath).row]
        return c
    }
}
