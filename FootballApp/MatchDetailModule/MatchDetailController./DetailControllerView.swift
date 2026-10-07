import UIKit


final class MatchDetailController: UIViewController {

    private let viewModel: MatchDetailViewModel

    init(viewModel: MatchDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.semiBold.font
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var headerView = MatchHeaderView()
    private lazy var segmentControl = MatchDetailSegmentControl()
    private lazy var statsView = MatchStatsView()
    private lazy var eventsView = MatchEventsView()
    private lazy var lineUpView = LineUpView()
    private lazy var h2hView = H2HView()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [headerView, segmentControl,eventsView,statsView, lineUpView, h2hView])
        stack.axis = .vertical
        stack.spacing = AppLayout.mediumSpacing.value
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(
            top: AppLayout.spacing.value,
            left: AppLayout.screenPadding.value,
            bottom: AppLayout.largeSpacing.value,
            right: AppLayout.screenPadding.value
        )
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AssetColors.background.color
        setupHierarchy()
        setupLayout()

        // Data gələnə qədər boş ekran görünməsin.
        scrollView.isHidden = true

        segmentControl.onTabSelected = { [weak self] tab in
            self?.showTab(tab)
        }
        bindViewModel()
        viewModel.load()
    }

    private func bindViewModel() {
        viewModel.onLoaded = { [weak self] data in
            self?.apply(data)
        }
        viewModel.onFailed = { [weak self] message in
            self?.showError(message)
        }
    }

    private func apply(_ data: MatchDetailData) {
        titleLabel.text = data.competitionName
        headerView.configure(
            homeName: data.homeName,
            awayName: data.awayName,
            homeCrest: data.homeCrest,
            awayCrest: data.awayCrest,
            score: data.score,
            minuteOrStatus: data.minuteOrStatus
        )
        statsView.configure(with: data.stats)
        eventsView.configure(events: data.events, hasStarted: data.hasStarted)
        lineUpView.configure(with: data.lineups)
        h2hView.configure(with: data.headToHead)

        scrollView.isHidden = false
        showTab(.matchDetail)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setupHierarchy() {
        scrollView.addSubviews(contentStack)
        view.addSubviews(backButton, titleLabel, scrollView)
    }

    private func setupLayout() {
        backButton
            .leading(view.leadingAnchor, AppLayout.screenPadding.value).0
            .top(view.safeAreaLayoutGuide.topAnchor, AppLayout.smallSpacing.value).0
            .width(32).0
            .height(32)

        titleLabel
            .centerX(view.centerXAnchor).0
            .centerY(backButton.centerYAnchor)

        scrollView
            .top(backButton.bottomAnchor, AppLayout.smallSpacing.value).0
            .leading(view.leadingAnchor).0
            .trailing(view.trailingAnchor).0
            .bottom(view.bottomAnchor)

        contentStack
            .top(scrollView.contentLayoutGuide.topAnchor).0
            .leading(scrollView.contentLayoutGuide.leadingAnchor).0
            .trailing(scrollView.contentLayoutGuide.trailingAnchor).0
            .bottom(scrollView.contentLayoutGuide.bottomAnchor).0
            .width(scrollView.frameLayoutGuide.widthAnchor)
    }

    private func showTab(_ tab: MatchDetailsTab) {
        eventsView.isHidden = tab != .matchDetail
        statsView.isHidden = tab != .statistics
        lineUpView.isHidden = tab != .lineUp
        h2hView.isHidden = tab != .h2h
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension MatchDetailController: HidesNavigationBar {}
