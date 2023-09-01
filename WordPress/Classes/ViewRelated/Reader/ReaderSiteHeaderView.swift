import SwiftUI

class ReaderSiteHeaderView: UIView, ReaderStreamHeader {

    weak var delegate: ReaderStreamHeaderDelegate?

    private lazy var headerViewModel: ReaderSiteHeaderViewModel = {
        ReaderSiteHeaderViewModel(onFollowTap: { [weak self] completion in
            guard let self else {
                return
            }
            self.delegate?.handleFollowActionForHeader(self, completion: completion)
        })
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .secondarySystemGroupedBackground
        setupHeader()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func enableLoggedInFeatures(_ enable: Bool) {
        headerViewModel.isFollowHidden = !enable
    }

    func configureHeader(_ topic: ReaderAbstractTopic) {
        guard let siteTopic = topic as? ReaderSiteTopic else {
            assertionFailure("This header should only be used for site topics.")
            return
        }
        headerViewModel.imageUrl = siteTopic.siteBlavatar
        headerViewModel.title = siteTopic.title
        headerViewModel.siteUrl = URL(string: siteTopic.siteURL)?.host ?? ""
        headerViewModel.siteDetails = siteTopic.siteDescription
        headerViewModel.postCount = siteTopic.postCount.doubleValue.abbreviatedString()
        headerViewModel.followerCount = siteTopic.subscriberCount.doubleValue.abbreviatedString()
        headerViewModel.isFollowingSite = siteTopic.following
    }

    private func setupHeader() {
        weak var weakSelf = self
        let header = ReaderSiteHeader(viewModel: weakSelf?.headerViewModel ?? ReaderSiteHeaderViewModel())
        let view = UIView.embedSwiftUIView(header)
        addSubview(view)
        pinSubviewToAllEdges(view)
    }

}

// MARK: - ReaderSiteHeader

struct ReaderSiteHeader: View {

    @StateObject var viewModel: ReaderSiteHeaderViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: URL(string: viewModel.imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .frame(width: 72.0, height: 72.0)
                        .clipShape(Circle())
                default:
                    Image(Constants.defaultSiteImage)
                        .resizable()
                        .frame(width: 72.0, height: 72.0)
                        .clipShape(Circle())
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.title)
                    .font(Font(WPStyleGuide.serifFontForTextStyle(.title2, fontWeight: .semibold)))
                Text(viewModel.siteUrl)
                    .font(.subheadline)
            }
            if !viewModel.siteDetails.isEmpty {
                Text(viewModel.siteDetails)
                    .lineLimit(3)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            countsDisplay
            if !viewModel.isFollowHidden {
                followButton
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
        .background(Color(UIColor.listForeground))
    }

    private var countsDisplay: some View {
        let countsString = String(format: Constants.countsFormat, viewModel.postCount, viewModel.followerCount)
        let stringItems = countsString.components(separatedBy: " ")

        return stringItems.reduce(Text(""), {
            var text = Text($1)
            if $1 == viewModel.postCount || $1 == viewModel.followerCount {
                text = text.font(.subheadline.weight(.semibold))
            } else {
                text = text.font(.subheadline).foregroundColor(.secondary)
            }
            return $0 + text + Text(" ")
        })
    }

    @ViewBuilder
    private var followButton: some View {
        if viewModel.isFollowingSite {
            Button {
                viewModel.updateFollowStatus()
            } label: {
                Image(uiImage: Constants.followingIcon ?? UIImage())
                    .padding(.leading, -2.0)
                    .padding(.trailing, 2.0)
                Text(WPStyleGuide.FollowButton.Text.followingStringForDisplay)
                    .padding(.leading, 2.0)
                    .padding(.trailing, -2.0)
                    .foregroundColor(.secondary)
                    .font(.callout)
            }
            .disabled(!viewModel.isFollowEnabled)
            .padding(.horizontal, 12.0)
            .padding(.vertical, 6.0)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(UIColor.primaryButtonBorder), lineWidth: 1)
            )
        } else {
            Button {
                viewModel.updateFollowStatus()
            } label: {
                Image(uiImage: Constants.followIcon ?? UIImage())
                    .padding(.leading, -2.0)
                    .padding(.trailing, 2.0)
                Text(WPStyleGuide.FollowButton.Text.followStringForDisplay)
                    .padding(.leading, 2.0)
                    .padding(.trailing, -2.0)
                    .foregroundColor(.white)
                    .font(.callout.weight(.semibold))
            }
            .disabled(!viewModel.isFollowEnabled)
            .padding(.horizontal, 12.0)
            .padding(.vertical, 6.0)
            .background(Color(UIColor.primary))
            .cornerRadius(4)
        }
    }

    struct Constants {
        static let defaultSiteImage = "blavatar-default"
        static let iconSide = WPStyleGuide.fontSizeForTextStyle(.callout)
        static let followIconSize = CGSize(width: iconSide, height: iconSide)
        static let followIcon = UIImage.gridicon(.readerFollow, size: followIconSize).imageWithTintColor(.white)
        static let followingIcon = UIImage.gridicon(.readerFollowing, size: followIconSize).imageWithTintColor(.buttonIcon)
        static let countsFormat = NSLocalizedString("reader.site.header.counts",
                                                    value: "%1$@ posts • %2$@ followers",
                                                    comment: "The formatted number of posts and followers for a site. " +
                                                    "'%1$@' is a placeholder for the site post count. " +
                                                    "'%2$@' is a placeholder for the site follower count. " +
                                                    "Example: `5,000 posts • 10M followers`")
    }

}

// MARK: - ReaderSiteHeaderViewModel

class ReaderSiteHeaderViewModel: ObservableObject {

    @Published var imageUrl: String
    @Published var title: String
    @Published var siteUrl: String
    @Published var siteDetails: String
    @Published var postCount: String
    @Published var followerCount: String
    @Published var isFollowingSite: Bool
    @Published var isFollowHidden: Bool
    @Published var isFollowEnabled: Bool

    private let onFollowTap: (_ completion: @escaping () -> Void) -> Void

    init(imageUrl: String = "",
         title: String = "",
         siteUrl: String = "",
         siteDetails: String = "",
         postCount: String = "",
         followerCount: String = "",
         isFollowingSite: Bool = false,
         isFollowHidden: Bool = false,
         isFollowEnabled: Bool = true,
         onFollowTap: @escaping (_ completion: @escaping () -> Void) -> Void = { _ in }) {
        self.imageUrl = imageUrl
        self.title = title
        self.siteUrl = siteUrl
        self.siteDetails = siteDetails
        self.postCount = postCount
        self.followerCount = followerCount
        self.isFollowingSite = isFollowingSite
        self.isFollowHidden = isFollowHidden
        self.isFollowEnabled = isFollowEnabled
        self.onFollowTap = onFollowTap
    }

    func updateFollowStatus() {
        isFollowEnabled = false
        onFollowTap { [weak self] in
            self?.isFollowEnabled = true
        }
    }

}
