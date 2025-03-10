//
//  DerivedDataListViewModel.swift
//  
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import Foundation
import CodePurgeKit

/// A view model for managing and displaying derived data folders.
///
/// This view model is responsible for handling the data and actions related to
/// derived data folders. It tracks the state of selected folders, provides
/// filtering functionality, and supports UI interactions such as toggling
/// selection states or selecting old folders.
final class DerivedDataListViewModel: BasePurgeObservableObject<DerivedDataFolder> {
    /// The sections of derived data folders, grouped for display in a list.
    @Published var sections: [DerivedDataSection] = []
    
    /// The number of days after which a folder is considered "old."
    private let oldFolderDayValue: Int
    
    /// The data source managing the list of derived data folders.
    private let datasource: PurgableItemDataSource<DerivedDataFolder>
    
    let error: ScanError?
    
    /// Initializes the view model with a specified number of days for old folders
    /// and a data source for managing derived data.
    ///
    /// - Parameters:
    ///   - oldFolderDayValue: The number of days after which a folder is considered old.
    ///                        Defaults to `30`.
    ///   - datasource: The data source managing the list of derived data folders.
    init(oldFolderDayValue: Int = 30, error: ScanError?, datasource: PurgableItemDataSource<DerivedDataFolder>) {
        self.error = error
        self.datasource = datasource
        self.oldFolderDayValue = oldFolderDayValue
        super.init(datasource: datasource)
        
        self.startObservers()
    }
}


// MARK: - Display Data
extension DerivedDataListViewModel {
    /// A Boolean indicating whether the "Select Old Folders" button should be shown.
    ///
    /// The button is shown when there are old folders that are not yet selected.
    var canShowSelectOldFoldersButton: Bool {
        return datasource.selectedItems.count != datasource.list.count && !getOldFolders().isEmpty
    }
}


// MARK: - Actions
extension DerivedDataListViewModel {
    /// Toggles the selection state of all derived data folders.
    func toggleSelectAll() {
        toggleAllItems(datasource.list)
    }
    
    /// Selects all derived data folders considered "old" based on the specified
    /// number of days (`oldFolderDayValue`).
    func selectOldFolders() {
        toggleAllItems(getOldFolders())
    }
}


// MARK: - Private Methods
private extension DerivedDataListViewModel {
    /// Starts observing changes in the data source and updates the sections accordingly.
    func startObservers() {
        datasource.$list
            .combineLatest($selectedItemCount)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .map { list, selectionCount in
                return [
                    .init(items: list, selectedItemCount: selectionCount)
                ]
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$sections)
    }
    
    /// Retrieves a list of derived data folders that are considered "old."
    ///
    /// A folder is considered "old" if its last modified date is older than
    /// the specified `oldFolderDayValue`.
    ///
    /// - Returns: An array of `DerivedDataFolder` objects that are considered old.
    func getOldFolders() -> [DerivedDataFolder] {
        return datasource.list.filter { folder in
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -oldFolderDayValue, to: Date()) ?? Date.distantPast
            guard let dateModified = folder.dateModified else {
                return true
            }
            return dateModified < thirtyDaysAgo
        }
    }
}
