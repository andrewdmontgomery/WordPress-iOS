import UIKit
import SwiftUI

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

struct ReadingStatsView: View {
    var body: some View {
        VStack(spacing: 24.0) {
            heroView
            favoriteBlogsView
        }
        .padding(.horizontal, 32.0)
    }

    var heroView: some View {
        VStack(spacing: 8.0) {
            Image("icon-reader-save-outline")
                .resizable()
                .scaledToFit()
                .frame(width: 24.0, height: 24.0)
                .padding(4.0)
                .foregroundColor(.white)
                .background(Circle().fill(.black))
            Text("47 mins")
                .font(.title)
                .fontWeight(.bold)
            Text("Reading time this week")
                .font(.subheadline)
                .fontWeight(.semibold)
            // TODO: Add trend-up icon.
            Text("You're in the top 10% of readers!")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    var favoriteBlogsView: some View {
        VStack(spacing: 8.0) {
            Text("YOUR FAVORITE BLOGS")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(alignment: .top) {
                ForEach(0..<3) { _ in // Replace with actual data
                    VStack {
                        Image("gravatar") // Replace with actual image
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 64.0, height: 64.0) // Adjust size as needed
                        Text("Culinary Wunderlust") // Replace with actual data
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity) // keeps the elements equally-sized within the HStack.
                }
            }
        }
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
        VStack(spacing: 16.0) {
            ReadingStatsView()
            Button(action: {
                buttonAction()
            }) {
                Text("Share with friends")
                    .font(.body)
                    .foregroundStyle(Color(uiColor: .jetpackGreen))
                    .padding(.vertical, 8.0)
            }
        }
        .padding(.bottom, 24.0)
        .sheet(isPresented: $isShareSheetPresented, onDismiss: {
            self.capturedImage = nil
        }, content: {
            if let image = self.capturedImage {
                ShareSheet(activityItems: [image])
            }
        })
    }
}



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

    private var viewForScreenshot: some View {
        VStack(spacing: 0) {
            ReadingStatsView()
                .padding([.top, .bottom], 10.0)
                .padding([.leading, .trailing], 20.0)
            Spacer()
        }
    }

    func takeScreenshot() -> UIImage? {
        let fauxHostingController = UIHostingController(rootView: viewForScreenshot)

        guard let viewToDraw = fauxHostingController.view,
              let hostedView = frameView.subviews.first else {
            return nil
        }

        let targetSize = hostedView.bounds.size
        viewToDraw.bounds = .init(origin: .zero, size: targetSize)
        viewToDraw.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            viewToDraw.drawHierarchy(in: hostedView.bounds, afterScreenUpdates: true)
        }
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
