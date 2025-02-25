//
//  DerivedDataSection.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import CodePurgeKit

/// Represents a section of derived data folders in a list view.
///
/// A section groups related `DerivedDataFolder` items and keeps track of the
/// number of selected items within the section.
struct DerivedDataSection: ListItemSection {
    /// The unique identifier for the derived data section.
    let id: String = "DerivedDataId"
    
    /// The name of the section, which is always "Derived Data".
    let name: String = "Derived Data"
    
    /// The list of derived data folders in this section.
    let items: [DerivedDataFolder]
    
    /// The number of items in this section that are currently selected.
    let selectedItemCount: Int
}
