//
//  ArchiveListViewModel.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import Foundation
import CodePurgeKit

/// A view model for managing archive folders and their hierarchical collections.
///
/// This view model handles operations such as toggling selection,
/// filtering old archives, and showing archive details in Finder.
/// It observes and updates the data for the list of archive folders.
final class ArchiveListViewModel: BasePurgeObservableObject<ArchivePurgeFolder> {
    @Published var listItems: [ArchiveListItem] = []
    @Published private var collections: [ArchivePurgeCollection] = []
    
    private let oldArchiveDayValue: Int
    private let datasource: PurgableItemDataSource<ArchivePurgeFolder>
    private let onShowInFinder: (URL) -> Void
    
    let error: DeveloperDataError?
    
    /// Initializes the view model with a specified data source and Finder action.
    ///
    /// - Parameters:
    ///   - oldArchiveDayValue: The number of days after which an archive is considered old. Default is `30`.
    ///   - datasource: The data source for managing archive folders.
    ///   - onShowInFinder: A closure to handle the "Show in Finder" action for a given URL.
    init(oldArchiveDayValue: Int = 30, error: DeveloperDataError?, datasource: PurgableItemDataSource<ArchivePurgeFolder>, onShowInFinder: @escaping (URL) -> Void) {
        self.error = error
        self.datasource = datasource
        self.onShowInFinder = onShowInFinder
        self.oldArchiveDayValue = oldArchiveDayValue
        super.init(datasource: datasource)
        
        self.startObservers()
    }
}


// MARK: - Actions
extension ArchiveListViewModel {
    /// Selects all archives that are considered "old."
    func selectOldArchives() {
        toggleAllItems(getOldArchives())
    }
    
    /// Opens the specified archive folder in Finder.
    ///
    /// - Parameter archive: The archive folder to open.
    func showInFinder(_ archive: ArchivePurgeFolder) {
        if let url = archive.url {
            onShowInFinder(url)
        }
    }
}


// MARK: - Observers
private extension ArchiveListViewModel {
    /// Retrieves a list of old archives based on the `oldArchiveDayValue`.
    ///
    /// - Returns: An array of `ArchivePurgeFolder` instances that are older than the specified threshold.
    func getOldArchives() -> [ArchivePurgeFolder] {
        return collections.flatMap { collection in
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -oldArchiveDayValue, to: Date()) ?? Date.distantPast
            
            return collection.items.filter { folder in
                guard let creationDate = folder.creationDate else {
                    return true
                }
                
                return creationDate < thirtyDaysAgo
            }
        }
    }
    
    /// Starts observing changes in the data source and updates the list of items and collections.
    func startObservers() {
        datasource.$list
            .combineLatest(datasource.$selectedItems)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .map { (archives, selectedItems) in
                return Dictionary(grouping: archives, by: { $0.name })
                    .map { key, values in
                        let selectedItemCount = values.filter({ selectedItems.contains($0) }).count
                        
                        return .init(name: key, items: values, selectedItemCount: selectedItemCount)
                    }
                    .sorted(by: { $0.name > $1.name })
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$collections)
        
        $collections
            .map { list in
                return list.map { collection in
                    return .init(
                        id: collection.id,
                        rowData: .section(collection),
                        children: collection.items.map({ .init(id: $0.id, rowData: .row($0), children: nil) })
                    )
                }
            }
            .assign(to: &$listItems)
    }
}
