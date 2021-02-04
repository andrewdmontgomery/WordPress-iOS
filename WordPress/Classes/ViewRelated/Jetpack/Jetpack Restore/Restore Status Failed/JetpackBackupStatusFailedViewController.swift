import UIKit
import CocoaLumberjack
import WordPressShared
import WordPressUI

class JetpackBackupStatusFailedViewController: BaseRestoreStatusFailedViewController {

    // MARK: - Initialization

    override init() {
        let configuration = RestoreStatusFailedConfiguration(
            title: NSLocalizedString("Backup", comment: "Title for Jetpack Backup Update Status Failed screen"),
            messageTitle: NSLocalizedString("Hmm, we can't find your backup status", comment: "Message title displayed when we fail to fetch the status of the backup in progress."),
            firstHint: NSLocalizedString("We don't have information on how long creating your backup will take.", comment: "Hint displayed when we fail to fetch the status of the backup in progress."),
            secondHint: NSLocalizedString("We'll still attempt to create a backup of your site.", comment: "Hint displayed when we fail to fetch the status of the backup in progress."),
            thirdHint: NSLocalizedString("We'll notify you when it's done.", comment: "Hint displayed when we fail to fetch the status of the backup in progress.")
        )
        super.init(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
