import Foundation

class ReaderTracker: NSObject {
    @objc static let shared = ReaderTracker()

    var readPosts: [Int] {
        get {
            UserDefaults.standard.value(forKey: "read_posts") as? [Int] ?? []
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "read_posts")
        }
    }

    var timeSpentReading: TimeInterval {
        get {
            UserDefaults.standard.value(forKey: "time_spent_reading") as? TimeInterval ?? 0
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "time_spent_reading")
            NotificationCenter.default.post(name: .timeSpentReadingDidChange, object: nil)
        }
    }

    enum Section: String, CaseIterable {
        /// Time spent in the main Reader view (the one with the tabs)
        case main = "time_in_main_reader"

        /// Time spent in the Following tab with an active filter
        case filteredList = "time_in_reader_filtered_list"

        /// Time spent reading article
        case readerPost = "time_in_reader_post"
    }

    private var now: () -> Date
    private var startTime: [Section: Date] = [:]
    private var totalTimeInSeconds: [Section: TimeInterval] = [:]

    init(now: @escaping () -> Date = { return Date() }) {
        self.now = now
    }

    /// Returns a dictionary with a key and the time spent in that section
    @objc func data() -> [String: Double] {
        return Section.allCases.reduce([String: Double]()) { dict, section in
            var dict = dict
            dict[section.rawValue] = totalTimeInSeconds[section] ?? 0
            return dict
        }
    }

    /// Start counting time spent for a given section
    func start(_ section: Section) {
        guard startTime[section] == nil else {
            return
        }

        startTime[section] = now()
    }

    /// Stop counting time spent for a given section
    func stop(_ section: Section, _ post: ReaderPost? = nil, _ scrollPercent: CGFloat? = nil) {
        guard let startTime = startTime[section] else {
            return
        }

        let timeSince = now().timeIntervalSince(startTime)

        totalTimeInSeconds[section] = (totalTimeInSeconds[section] ?? 0) + round(timeSince)
        self.startTime.removeValue(forKey: section)

        if let post, post.isSavedForLater, let scrollPercent, let timeSpent = totalTimeInSeconds[section] {
            let readingTimeInSeconds = post.readingTime.doubleValue * 60.0
            let timePercent = readingTimeInSeconds > 0 ? timeSpent / readingTimeInSeconds : 1.0

            if timePercent > 0.5 && scrollPercent > 0.5,
                let postID = post.postID?.intValue,
               !readPosts.contains(postID) {
                var currentPosts = readPosts
                currentPosts.append(postID)
                readPosts = currentPosts
            }
        }

        if section == .readerPost {
            timeSpentReading += totalTimeInSeconds[section] ?? 0
        }
    }

    /// Stop counting time for all sections
    @objc func stopAll() {
        Section.allCases.forEach { stop($0) }
    }

    /// Stop counting time for all sections and reset them to zero
    @objc func reset() {
        startTime = [:]
        totalTimeInSeconds = [:]
    }
}
