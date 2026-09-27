//
//  HomeController.swift
//  FootballApp
//
//  Created by Servan on 27.09.26.
//

import UIKit

final class HomeController: UIViewController {
    
    private lazy var headLabel: UILabel = {
        let label = UILabel()
        label.text = "QSscore"
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .white
        return label
    }()
    private lazy var notificationButton: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "notificationicon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var searchButton: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "searchicon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "mbappeback")
        setupLayout()
        configureNavbar()
    }
    private func configureNavbar() {
        navigationController?.navigationBar.isHidden = true
    }
    private func setupLayout() {
        view.addSubviews(headLabel,notificationButton,searchButton)
        
        headLabel
            .leading(view.leadingAnchor,AppLayout.mediumSpacing.value).0
            .top(view.safeAreaLayoutGuide.topAnchor,AppLayout.mediumSpacing.value)
        notificationButton
            .trailing(view.trailingAnchor, -AppLayout.mediumSpacing.value).0
            .centerY(headLabel.centerYAnchor).0
            .height(30).0
            .width(30)
        searchButton
            .trailing(notificationButton.leadingAnchor, -AppLayout.mediumSpacing.value).0
            .centerY(headLabel.centerYAnchor).0
            .height(30).0
            .width(30)
    }
}
