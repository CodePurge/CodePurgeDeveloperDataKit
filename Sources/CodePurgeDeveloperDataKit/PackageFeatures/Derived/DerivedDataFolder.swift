//
//  DerivedDataFolder.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import Foundation
import CodePurgeKit

/// Represents a derived data folder created by Xcode.
///
/// A derived data folder contains temporary files used by Xcode to improve
/// build times and manage project indexes. These folders can be purged
/// when they are no longer needed or become too large.
public struct DerivedDataFolder: PurgableItem {
    public let id: String
    public let url: URL?
    public let name: String
    public let size: Int64
    public let dateModified: Date?
    
    /// The type of purgable item, which is always `.derivedData` for this struct.
    public var type: PurgableItemType {
        return .derivedData
    }
    
    /// Creates a new instance of `DerivedDataFolder`.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the folder.
    ///   - url: The file URL of the folder.
    ///   - name: The name of the folder.
    ///   - size: The size of the folder in bytes.
    ///   - dateModified: The last modification date of the folder.
    public init(id: String, url: URL?, name: String, size: Int64, dateModified: Date?) {
        self.id = id
        self.url = url
        self.name = name
        self.size = size
        self.dateModified = dateModified
    }
}
