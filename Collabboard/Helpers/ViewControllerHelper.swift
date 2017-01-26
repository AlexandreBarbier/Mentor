//
//  ViewControllerHelper.swift
//  Collabboard
//
//  Created by Alexandre barbier on 26/01/2017.
//  Copyright © 2017 Alexandre Barbier. All rights reserved.
//

import UIKit

extension UIViewController {

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        present(alert, animated: true, completion: nil)
    }

}
