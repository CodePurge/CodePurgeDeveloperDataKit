//
//  DocumentationCacheListViewModel.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import Foundation
import CodePurgeKit

/// View model for managing a list of cached documentation folders.
///
/// This view model provides functionality to display, filter, and interact with
/// cached documentation folders, including identifying the current version and
/// listing older versions.
final class DocumentationCacheListViewModel: BasePurgeObservableObject<DocumentationFolder> {
    /// The version of Xcode currently being used, if available.
    private let xcodeVersion: String?
    
    /// The data source managing the list of documentation folders.
    private let datasource: PurgableItemDataSource<DocumentationFolder>
    
    let error: ScanError?
    
    /// Initializes a new instance of `DocumentationCacheListViewModel`.
    ///
    /// - Parameters:
    ///   - xcodeVersion: The current version of Xcode, used to identify the current documentation folder.
    ///   - datasource: The data source for managing documentation folder data.
    init(xcodeVersion: String?, error: ScanError?, datasource: PurgableItemDataSource<DocumentationFolder>) {
        self.xcodeVersion = xcodeVersion
        self.datasource = datasource
        self.error = error
        super.init(datasource: datasource)
    }
}


// MARK: - Display Data
extension DocumentationCacheListViewModel {
    /// The list of documentation folders that are not the current version.
    var olderDocVersions: [DocumentationFolder] {
        return datasource.list.filter({ $0.id != currentDocVersion?.id })
    }
    
    /// The documentation folder corresponding to the current version of Xcode, if available.
    var currentDocVersion: DocumentationFolder? {
        guard let xcodeVersion else { return nil }
        return datasource.list.first(where: { $0.name == xcodeVersion })
    }
}
