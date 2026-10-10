//
//  PrivacyPolicyController.swift
//  FootballApp
//
//  Created by Servan on 10.10.26.
//


//
//  PrivacyPolicyController.swift
//  FootballApp
//

import UIKit

final class PrivacyPolicyController: UIViewController {

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.textColor = .labelColor
        textView.font = AppFonts.body.font
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 20, bottom: 24, right: 20)
        textView.text = PrivacyPolicyController.policyText
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Privacy Policy"
        view.backgroundColor = AssetColors.backgroundColor2.color
        view.addSubviews(textView)
        textView
            .top(view.safeAreaLayoutGuide.topAnchor).0
            .leading(view.leadingAnchor).0
            .trailing(view.trailingAnchor).0
            .bottom(view.bottomAnchor)
    }

    // TODO: Nümunə mətn. Real Privacy Policy mətni ilə əvəz et.
    private static let policyText = """
    What we collect
    When you create an account we store your username and email address. Your password is handled by our authentication provider and is never visible to us.

    How we use it
    We use this information to create and secure your account and to show you the matches and notifications you chose to follow.

    Where it is stored
    Account data is stored with Firebase Authentication. You can sign out at any time from your profile.

    Contact
    If you have questions about your data, contact the app team.
    """
}