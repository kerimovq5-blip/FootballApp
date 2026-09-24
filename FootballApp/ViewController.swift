//
//  ViewController.swift
//  FootballApp
//
//  Created by Servan on 23.09.26.
//


import UIKit

class ViewController: UIViewController {

    var onSignUpTapped: (() -> Void)?
    var onSignInTapped: (() -> Void)?

    private lazy var backview: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "mbappeback")
        view.layer.cornerRadius = 58
        return view
    }()

    private lazy var firstPageImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "mbappe")
        image.contentMode = .scaleAspectFit
        return image
    }()

    private lazy var introductionLabel: UILabel = {
        let label = UILabel()
        let attributed = NSMutableAttributedString(
            string: "Discover all about sport",
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 40, weight: .bold)
            ]
        )
        attributed.append(
            NSAttributedString(
                string: "\n\nSearch millions of jobs and get the inside scoop on companies. Wait for what? Let’s get start it!",
                attributes: [
                    .foregroundColor: UIColor.gray,
                    .font: UIFont.systemFont(ofSize: 16, weight: .regular)
                ]
            )
        )
        label.attributedText = attributed
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private lazy var signInButton: AppButton = {
        let button = AppButton(
            title: "Sign in",
            backgroundColor: .accent
            
        )
        button.onTap = { [weak self] in
            self?.onSignInTapped?()
        }
        return button
    }()

    private lazy var signUpButton: AppButton = {
        let button = AppButton(
            title: "Sign Up",
            titleColor: .buttonTitlecolor
        )
        button.onTap = { [weak self] in
            self?.onSignUpTapped?()
        }
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AssetColors.background.color
        view.addSubviews(
                backview,
                firstPageImage,
                introductionLabel,
                signUpButton,
                signInButton
            )

        backview
            .centerX(view.centerXAnchor).0
            .top(view.safeAreaLayoutGuide.topAnchor, 100).0
            .width(300).0
            .height(300)

        firstPageImage
            .bottom(backview.bottomAnchor).0
            .centerX(backview.centerXAnchor).0
            .width(260).0
            .height(350)

        introductionLabel
            .top(firstPageImage.bottomAnchor, 50).0
            .leading(backview.leadingAnchor).0
            .trailing(backview.trailingAnchor, -50)

        signInButton
            .top(introductionLabel.bottomAnchor, AppLayout.largeSpacing.value).0
            .leading(backview.leadingAnchor).0
            .width(199).0
            .height(63)

        signUpButton
            .centerY(signInButton.centerYAnchor).0
            .leading(
                signInButton.trailingAnchor,
                AppLayout.smallSpacing.value
            ).0
            .trailing(backview.trailingAnchor)
    }
}
