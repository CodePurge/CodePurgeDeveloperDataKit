//
//  ScannedDeveloperCategoryInfo.swift
//
//
//  Created by Nikolai Nobadi on 1/4/25.
//

import CodePurgeKit

/// Represents information about a scanned developer category.
/// This is used to display the results of a scan, including total size and selected size.
struct ScannedDeveloperCategoryInfo: ScannedCategoryInfo {
    /// The developer data category associated with this scan result.
    let category: DeveloperDataCategory
    
    /// The total size of the scanned data in the category.
    let size: Int64
    
    /// The size of the data selected for purging in the category.
    let selectedSize: Int64
}
