//
//  DocumentationFolder.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import Foundation
import CodePurgeKit

/// Represents a folder containing cached Apple API documentation.
///
/// The documentation cache is used for offline access to Apple API documentation,
/// improving the speed of loading documentation pages in Xcode.
public struct DocumentationFolder: PurgableItem {
    /// The unique identifier for the documentation folder.
    public let id: String
    
    /// The URL of the documentation folder, if available.
    public let url: URL?
    
    /// The name of the documentation folder, typically representing the version or SDK name.
    public let name: String
    
    /// The total size of the documentation folder in bytes.
    public let size: Int64
    
    /// The date the documentation folder was last modified, if available.
    public let dateModified: Date?
    
    /// The name of the parent folder where the documentation cache is located.
    public let parentFolderName: String
    
    /// The type of purgable item, identifying this as a documentation cache folder.
    public var type: PurgableItemType {
        return .documentation
    }
    
    /// Initializes a new instance of `DocumentationFolder`.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the folder.
    ///   - url: The URL of the folder.
    ///   - name: The name of the folder.
    ///   - size: The size of the folder in bytes.
    ///   - dateModified: The date the folder was last modified.
    ///   - parentFolderName: The name of the parent folder.
    public init(id: String, url: URL?, name: String, size: Int64, dateModified: Date?, parentFolderName: String) {
        self.id = id
        self.url = url
        self.name = name
        self.size = size
        self.dateModified = dateModified
        self.parentFolderName = parentFolderName
    }
}
