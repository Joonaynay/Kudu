//
//  ContactUsViewController.swift
//  StarFeed
//
//  Created by Wendy Buhler on 11/4/21.
//

import UIKit
import MessageUI
import SafariServices

class ContactUsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    private let emailButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .link
        button.setTitle("Contact Us", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addConstraints()
    }
    
    private func setupView() {
        view.addSubview(emailButton)
        emailButton.addAction(UIAction() { _ in
            if MFMailComposeViewController.canSendMail() {
                let mailComposeVC = MFMailComposeViewController()
                mailComposeVC.mailComposeDelegate = self
                mailComposeVC.setSubject("Contact Us / Feedback")
                mailComposeVC.setToRecipients(["tbuhler347@gmail.com"])
                mailComposeVC.setMessageBody("Hello, \nWe would love to hear your feedback. Feel free to contact us. Thanks!\n\nYThe starFeed team", isHTML: false)
                self.present(mailComposeVC, animated: true)
            } else {
                guard let url = URL(string: "https://www.google.com") else { return }
                let safariVC = SFSafariViewController(url: url)
                self.present(safariVC, animated: true)
            }
        }, for: .touchUpInside)
    }
    
    private func addConstraints() {
        emailButton.height(50)
        emailButton.horizontalToSuperview()
        emailButton.centerXToSuperview()
        emailButton.centerYToSuperview()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
