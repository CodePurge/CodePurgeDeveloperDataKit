//
//  ArchivePurgeCollection.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import Foundation
import CodePurgeKit

/// Represents a collection of archive folders.
///
/// A collection groups multiple `ArchivePurgeFolder` items under a common name,
/// allowing for easier organization and display in lists or sections.
struct ArchivePurgeCollection: ListItemSection {
    /// The name of the collection.
    let name: String
    
    /// The list of archive folders in the collection.
    let items: [ArchivePurgeFolder]
    
    /// The number of selected items in the collection.
    let selectedItemCount: Int
}
