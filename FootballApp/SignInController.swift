//
//  SignInController.swift
//  FootballApp
//
//  Created by Servan on 24.09.26.
//

import UIKit

final class SignInController: UIViewController, UISheetPresentationControllerDelegate {
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome"
        label.textColor = .white
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.gray
            ]
        )
        textField.textColor = .white
        textField.layer.cornerRadius = 16
        textField.keyboardType = .emailAddress
        let imageView = UIImageView(image: UIImage(named: "emailicon"))
            
            imageView.frame = CGRect(
                x: 0,
                y: 0,
                width: 24,
                height: 24
            )
            let container = UIView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: 48,
                    height: 64
                )
            )
            imageView.center = container.center
            container.addSubview(imageView)

            textField.leftView = container
            textField.leftViewMode = .always
        textField.backgroundColor = AssetColors.background.color
        return textField
    }()
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.gray
            ]
        )
        textField.textColor = .white
        textField.layer.cornerRadius = 16
        textField.isSecureTextEntry = true
        let imageView = UIImageView(image: UIImage(named: "passwordicon"))
            imageView.frame = CGRect(
                x: 0,
                y: 0,
                width: 24,
                height: 24
            )
            let container = UIView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: 48,
                    height: 64
                )
            )
            imageView.center = container.center
            container.addSubview(imageView)

            textField.leftView = container
            textField.leftViewMode = .always
        let imageView1 = UIImageView(image: UIImage(named: "hidepassword"))
            imageView1.frame = CGRect(
                x: 0,
                y: 0,
                width: 24,
                height: 24
            )
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hidepassword))
        imageView1.addGestureRecognizer(gesture)
        imageView1.isUserInteractionEnabled = true
        
            let container1 = UIView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: 48,
                    height: 64
                )
            )
            imageView1.center = container1.center
            container1.addSubview(imageView1)

            textField.rightView = container1
            textField.rightViewMode = .always
        textField.backgroundColor = AssetColors.background.color
        return textField
    }()
    @objc func hidepassword(){
        passwordTextField.isSecureTextEntry.toggle()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "mbappeback")
        view.addSubviews(welcomeLabel,emailTextField,passwordTextField)
        welcomeLabel
            .leading(view.leadingAnchor,24).0
            .top(view.safeAreaLayoutGuide.topAnchor,40)
        emailTextField
            .leading(view.leadingAnchor,24).0
            .trailing(view.trailingAnchor,-24).0
            .top(welcomeLabel.bottomAnchor,70).0
            .height(75)
        passwordTextField
            .leading(view.leadingAnchor,24).0
            .trailing(view.trailingAnchor,-24).0
            .top(emailTextField.bottomAnchor,36).0
            .height(75)
    }
}
