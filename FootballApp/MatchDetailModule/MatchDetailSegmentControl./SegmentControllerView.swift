//
//  SegmentControllerView.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 30.09.26.
//

import UIKit


    final class MatchDetailSegmentControl: UIView {
        var onTabSelected: ((MatchDetailsTab) -> Void)?
        
        private var buttons: [UIButton] = []
        private var selectedTab: MatchDetailsTab = .matchDetail {
            didSet { updateAppearance() }
        }
        
        private lazy var stack: UIStackView = {
            let s = UIStackView()
            s.axis = .horizontal
            s.spacing = AppLayout.smallSpacing.value
            s.distribution = .fillEqually
            return s
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubviews(stack)
            stack
                .top(topAnchor).0
                .leading(leadingAnchor).0
                .trailing(trailingAnchor).0
                .bottom(bottomAnchor)
            
            for (index, tab) in MatchDetailsTab.allCases.enumerated() {
                let button = UIButton(type: .system)
                button.setTitle(tab.title, for: .normal)
                button.titleLabel?.font = AppFonts.semiBold.font
                button.layer.cornerRadius = 18
                button.tag = index
                button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
                buttons.append(button)
                stack.addArrangedSubview(button)
            }
            updateAppearance()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc private func tapped(_ sender: UIButton) {
            let tab = MatchDetailsTab.allCases[sender.tag]
            selectedTab = tab
            onTabSelected?(tab)
        }
        
        private func updateAppearance() {
            for (index, button) in buttons.enumerated() {
                let isSelected = MatchDetailsTab.allCases[index] == selectedTab
                button.backgroundColor = isSelected ? .white : UIColor.white.withAlphaComponent(0.12)
                button.setTitleColor(isSelected ? .black : .white, for: .normal)
            }
        }
    }

