import UIKit

final class MatchDetailSegmentControl: UIView {

    var onTabSelected: ((MatchDetailsTab) -> Void)?

    private lazy var tabBar = PillTabBar(
        titles: MatchDetailsTab.allCases.map { $0.title },
        alignment: .spread
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(tabBar)
        tabBar
            .top(topAnchor).0
            .leading(leadingAnchor).0
            .trailing(trailingAnchor).0
            .bottom(bottomAnchor)

        tabBar.onSelect = { [weak self] index in
            self?.onTabSelected?(MatchDetailsTab.allCases[index])
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
