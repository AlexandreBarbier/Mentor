//
//  ViewControllerHelper.swift
//  Collabboard
//
//  Created by Alexandre barbier on 26/01/2017.
//  Copyright © 2017 Alexandre Barbier. All rights reserved.
//

import UIKit
import MessageUI

extension UIViewController: UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        present(alert, animated: true, completion: nil)
    }

    func showMailController(subject: String, body: String) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setSubject(subject)
            mailComposer.delegate = self
            mailComposer.mailComposeDelegate = self
            present(mailComposer, animated: true, completion: nil)
        } else {
            showAlert(title: "Cannot send email", message: "please configure your mail client")
        }
    }

    public func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
