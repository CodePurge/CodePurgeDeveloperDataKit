//
//  ArchivePurgeFolder.swift
//  
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import Foundation
import CodePurgeKit

/// Represents an archive folder in Xcode.
///
/// This struct contains metadata about an archive folder, such as its name,
/// size, and modification dates. Archive folders are typically used for
/// packaging app builds for distribution (e.g., App Store or TestFlight).
public struct ArchivePurgeFolder: PurgableItem {
    public let id: String
    public let url: URL?
    public let name: String
    public let size: Int64
    public let imageData: Data?
    public let creationDate: Date?
    public let dateModified: Date?
    public let versionNumber: String?
    public let uploadStatus: String?
    
    public var type: PurgableItemType {
        return .archives
    }
    
    /// Initializes an archive folder with the given parameters.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the folder.
    ///   - url: The file URL of the folder.
    ///   - name: The name of the folder.
    ///   - size: The size of the folder in bytes.
    ///   - imageData: Optional image data for the folder (e.g., app icon).
    ///   - creationDate: Optional creation date of the folder.
    ///   - dateModified: Optional last modified date of the folder.
    ///   - versionNumber: Optional version number of the archive.
    ///   - uploadStatus: Optional upload status of the archive.
    public init(id: String, url: URL?, name: String, size: Int64, imageData: Data?, creationDate: Date?, dateModified: Date?, versionNumber: String?, uploadStatus: String?) {
        self.id = id
        self.url = url
        self.name = name
        self.size = size
        self.imageData = imageData
        self.creationDate = creationDate
        self.dateModified = dateModified
        self.versionNumber = versionNumber
        self.uploadStatus = uploadStatus
    }
}
