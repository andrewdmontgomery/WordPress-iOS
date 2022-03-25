import UIKit

@objc class QuickStartCell: UITableViewCell {

    private lazy var tourStateView: QuickStartTourStateView = {
        let view = QuickStartTourStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    @objc func configure(blog: Blog, viewController: BlogDetailsViewController) {
        contentView.addSubview(tourStateView)
        contentView.pinSubviewToAllEdges(tourStateView, insets: Metrics.margins)

        selectionStyle = .none

        tourStateView.configure(blog: blog, sourceController: viewController)
    }

    private enum Metrics {
        static let margins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}
