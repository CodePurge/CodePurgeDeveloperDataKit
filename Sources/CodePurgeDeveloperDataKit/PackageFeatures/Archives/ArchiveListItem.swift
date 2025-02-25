//
//  ArchiveListItem.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import Foundation
import CodePurgeKit

/// Represents a hierarchical list item for archives.
///
/// A list item can represent either an `ArchivePurgeFolder` or an
/// `ArchivePurgeCollection`, and may have child items for nested lists.
struct ArchiveListItem: ListItem {
    /// The unique identifier for the list item.
    let id: String
    
    /// The data associated with the list item, which can represent a row
    /// (`ArchivePurgeFolder`) or a section (`ArchivePurgeCollection`).
    let rowData: ListRowItemData<ArchivePurgeFolder, ArchivePurgeCollection>
    
    /// The child items of the current list item, if any.
    let children: [ArchiveListItem]?
}


// MARK: - Extension Helpers
extension ArchivePurgeCollection {
    /// Converts an `ArchivePurgeCollection` to an `ArchiveListItem`
    /// for use in hierarchical lists.
    ///
    /// - Returns: An `ArchiveListItem` with the collection as the section
    ///   and its items as children.
    func toListItem() -> ArchiveListItem {
        return .init(id: id, rowData: .section(self), children: items.map({ $0.toListItem() }))
    }
}

extension ArchivePurgeFolder {
    /// Converts an `ArchivePurgeFolder` to an `ArchiveListItem`
    /// for use in hierarchical lists.
    ///
    /// - Returns: An `ArchiveListItem` with the folder as the row
    ///   and no children.
    func toListItem() -> ArchiveListItem {
        return .init(id: id, rowData: .row(self), children: nil)
    }
}
