
final class DashboardReadingStatsViewModel {
    private enum Constants {
        static let transferDomainsURL = "https://wordpress.com/transfer-google-domains/"
    }

    private let tracker: EventTracker
//    weak var cell: DashboardGoogleDomainsCardCellProtocol?

    init(tracker: EventTracker = DefaultEventTracker()) {
        self.tracker = tracker
    }

    func didShowCard() {
        //tracker.track(.domainTransferShown)
    }

    func didTapTransferDomains() {
        guard let url = URL(string: Constants.transferDomainsURL) else {
            return
        }

        //cell?.presentGoogleDomainsWebView(with: url)
        tracker.track(.domainTransferButtonTapped)
    }

    func didTapMore() {
        tracker.track(.domainTransferMoreTapped)
    }
}

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {

    }
}

struct DashboardReadingStatsCardView: View {
    var buttonAction: () -> ()
    @State private var capturedImage: UIImage?
    @State private var isShareSheetPresented = false

    init(buttonAction: @escaping () -> ()) {
        self.buttonAction = buttonAction
    }

    var body: some View {
        VStack(spacing: Length.Padding.double) {
            readingThisWeekStack
            mostReadBlogsStack
        }
        .padding([.leading, .trailing, .bottom], Length.Padding.double)
        .onAppear {
            //WPAnalytics.track(.domainTransferShown)
        }
        .sheet(isPresented: $isShareSheetPresented, onDismiss: {
            self.capturedImage = nil
        }, content: {
            if let image = self.capturedImage {
                ShareSheet(activityItems: [image])
            }
        })
    }

    private var readingThisWeekStack: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("47mins")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Reading this week")
                    .font(.body)
                    .foregroundColor(.secondary)
                Spacer()
            }
            HStack {
                Text("Top 10%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                Image("icon-reader-star-outline")
                    .renderingMode(.template)
                    .foregroundColor(.green)
                Spacer()
            }
        }
    }

    private var mostReadBlogsStack: some View {
        VStack(spacing: 10) {
            HStack {
                Text("YOUR MOST READ BLOGS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
            }

            ForEach(0..<3) { _ in
                HStack {
                    Image("icon-tab-me") // Replace with actual image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44) // Adjust size as needed
                        .clipShape(Circle())
                    VStack(alignment: .leading) {
                        Text("Culinary Wanderlust")
                            .font(.headline)
                        Text("culinarywanderlust.wordpress.com")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
            }
            Spacer()

            Button(action: {
                buttonAction()
            }) {
                HStack {
                    Text("Share with friends")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }.padding(.vertical)
            }
        }
    }
}





import UIKit
import SwiftUI


final class DashboardReadingStatsCell: DashboardCollectionViewCell {
    private let frameView = BlogDashboardCardFrameView()
    private weak var presentingViewController: UIViewController?
    private var didConfigureHostingController = false

    var viewModel: DashboardReadingStatsViewModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFrameView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(blog: Blog, viewController: BlogDashboardViewController?, apiResponse: BlogDashboardRemoteEntity?) {
        self.presentingViewController = viewController

        if let presentingViewController, !didConfigureHostingController {
            self.viewModel = DashboardReadingStatsViewModel()
            let cardView = DashboardReadingStatsCardView(buttonAction: { [weak self] in
                let image = self?.takeScreenshot()
                let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self // For iPads
                self?.presentingViewController?.present(activityViewController, animated: true)
            })
            let hostingController = UIHostingController(rootView: cardView)

            guard let cardView = hostingController.view else {
                return
            }

            frameView.add(subview: cardView)

            presentingViewController.addChild(hostingController)

            cardView.backgroundColor = .clear
            frameView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(frameView)
            contentView.pinSubviewToAllEdges(frameView, priority: .defaultHigh)
            hostingController.didMove(toParent: presentingViewController)
            configureMoreButton(with: blog)

            viewModel?.didShowCard()

            didConfigureHostingController = true
        }
    }

    private func setupFrameView() {
        frameView.setTitle("Reading stats")
        frameView.onEllipsisButtonTap = { [weak self] in
            self?.viewModel?.didTapMore()
        }
        frameView.ellipsisButton.showsMenuAsPrimaryAction = true
        frameView.onViewTap = { [weak self] in
            guard let self else {
                return
            }

            self.viewModel?.didTapTransferDomains()
        }
    }

    private func configureMoreButton(with blog: Blog) {
        frameView.addMoreMenu(
            items:
                [
                    UIMenu(
                        options: .displayInline,
                        children: [
                            BlogDashboardHelpers.makeHideCardAction(for: .googleDomains, blog: blog)
                        ]
                    )
                ],
            card: .googleDomains
        )
    }

    func takeScreenshot() -> UIImage? {
        guard let hostingView = frameView.subviews.first else { return nil }
        let renderer = UIGraphicsImageRenderer(size: hostingView.bounds.size)
        let image = renderer.image { ctx in
            hostingView.drawHierarchy(in: hostingView.bounds, afterScreenUpdates: true)
        }
        return image
    }
}

private extension DashboardReadingStatsCell {
    enum Strings {
        static let cardTitle = NSLocalizedString(
            "mySite.domain.focus.cardCell.title",
            value: "News",
            comment: "Title for the domain focus card on My Site"
        )
    }
}
