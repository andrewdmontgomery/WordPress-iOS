import SwiftUI
import PhotosUI

struct MediaUploadProgressView: View {
    let state: State
    let title: String
    let description: String
    let buttonTitle: String?
    let buttonAction: (() -> Void)?

    init(state: State,
         title: String,
         description: String,
         buttonTitle: String? = nil,
         buttonAction: (() -> Void)? = nil
    ) {
        self.state = state
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }

    enum State {
        case loading
        case success
        case failure
    }

    var body: some View {
        VStack(spacing: 16) {
            switch state {
            case .loading:
                ProgressView()
            case .success:
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.green)
            case .failure:
                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.red)
            }

            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)

            if let buttonTitle {
                Button(buttonTitle) {
                    buttonAction?()
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)
            }
        }
        .padding(24)
    }
}

#Preview {
    MediaUploadProgressView(
        state: .loading,
        title: "Uploading media",
        description: "The images will appear on web when they are done"
    )
}

#Preview {
    MediaUploadProgressView(
        state: .success,
        title: "Media uploaded",
        description: "Check web to see your freshly uploaded media"
    )
}

#Preview {
    MediaUploadProgressView(
        state: .failure,
        title: "Upload failed",
        description: "You couldn't send your media to web",
        buttonTitle: "Retry"
    )
}
