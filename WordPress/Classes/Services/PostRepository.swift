import Foundation

final class PostRepository {

    enum Error: Swift.Error {
        case postNotFound
        case unknown
    }

    private let coreDataStack: CoreDataStackSwift
    private let remoteFactory: PostServiceRemoteFactory

    init(coreDataStack: CoreDataStackSwift, remoteFactory: PostServiceRemoteFactory = PostServiceRemoteFactory()) {
        self.coreDataStack = coreDataStack
        self.remoteFactory = remoteFactory
    }

    /// Sync a specific post from the API
    ///
    /// - Parameters:
    ///   - postID: The ID of the post to sync
    ///   - blogID: The blog that has the post.
    /// - Returns: The stored post object id.
    func getPost(withID postID: NSNumber, from blogID: CoreDataObjectIdentifier<Blog>) async throws -> CoreDataObjectIdentifier<AbstractPost> {
        let remote = try await coreDataStack.performQuery { [remoteFactory] in
            let blog = try blogID.existingObject(in: $0)
            return remoteFactory.forBlog(blog)
        }

        // TODO: In which case would remote be nil?
        guard let remote else {
            throw PostRepository.Error.unknown
        }

        let remotePost: RemotePost? = try await withCheckedThrowingContinuation { continuation in
            remote.getPostWithID(
                postID,
                success: { continuation.resume(returning: $0) },
                failure: { continuation.resume(throwing: $0 ?? PostRepository.Error.unknown ) }
            )
        }

        guard let remotePost else {
            throw PostRepository.Error.postNotFound
        }

        return try await coreDataStack.performAndSave { context in
            let blog = try blogID.existingObject(in: context)

            let post: AbstractPost
            if let existingPost = blog.lookupPost(withID: postID, in: context) {
                post = existingPost
            } else {
                if remotePost.type == PostServiceType.page.rawValue {
                    post = blog.createPage()
                } else {
                    post = blog.createPost()
                }
            }

            return try .ofUnsaved(post)
        }
    }

}
