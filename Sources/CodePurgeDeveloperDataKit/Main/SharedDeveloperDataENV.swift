//
//  SharedDeveloperDataENV.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import Foundation
import CodePurgeKit

/// An environment object for managing shared developer data across different categories.
///
/// This environment object tracks scan states, selected items, and provides shared data sources
/// for archives, derived data, and documentation cache. It also handles actions like starting
/// scans, toggling categories, and purging selected items.
final class SharedDeveloperDataENV: ObservableObject, ScanViewDelegate {
    @Published var totalSelectedCount: Int = 0
    @Published var totalSelectedSize: Int64 = 0
    @Published var scanState: ScanState = .notStarted
    @Published var confirmPurgeInfo: ConfirmPurgeInfo?
    @Published var selectedCategory: ScannedDeveloperCategoryInfo?
    @Published var categoryErrors: [DeveloperDataCategory: DeveloperDataError] = [:]
    @Published var categoriesToScan: Set<DeveloperDataCategory> = Set(DeveloperDataCategory.allCases)
    @Published private var currentCategoryBeingScanned: DeveloperDataCategory?
    
    private let delegate: DeveloperDataDelegate
    private let loadProgressDatasource = ProgressInfoDatasource()
    
    let derivedDataSource: PurgableItemDataSource<DerivedDataFolder> = .init()
    let archiveDataSource: PurgableItemDataSource<ArchivePurgeFolder> = .init()
    let docCacheDataSource: PurgableItemDataSource<DocumentationFolder> = .init()
    let deviceSupportDatasource: PurgableItemDataSource<DeviceSupportFolder> = .init()
    
    /// Initializes the environment object with a specified delegate.
    ///
    /// - Parameter delegate: The delegate responsible for handling actions like purging and loading data.
    init(delegate: DeveloperDataDelegate) {
        self.delegate = delegate
        
        $currentCategoryBeingScanned
            .compactMap { $0 }
            .combineLatest(loadProgressDatasource.$progressInfo.compactMap({ $0 }))
            .map { category, progressInfo in
                return .inProgress(.init(category: category.name, progress: progressInfo))
            }
            .assign(to: &$scanState)
        
        derivedDataSource.$selectedItems
            .combineLatest(archiveDataSource.$selectedItems, docCacheDataSource.$selectedItems, deviceSupportDatasource.$selectedItems)
            .map { $0.count + $1.count + $2.count + $3.count }
            .assign(to: &$totalSelectedCount)
        
        derivedDataSource.$selectedSize
            .combineLatest(archiveDataSource.$selectedSize, docCacheDataSource.$selectedSize, deviceSupportDatasource.$selectedSize)
            .map { $0 + $1 + $2 + $3 }
            .assign(to: &$totalSelectedSize)
    }
}


// MARK: - Display Data
extension SharedDeveloperDataENV {
    var showingPurgeFooter: Bool {
        return scanState == .finished && selectedCategory == nil
    }
}


// MARK: - Actions
extension SharedDeveloperDataENV {
    func startOver() {
        scanState = .notStarted
        archiveDataSource.resetDatasource()
        derivedDataSource.resetDatasource()
        docCacheDataSource.resetDatasource()
        deviceSupportDatasource.resetDatasource()
    }
    
    func showInFinder(url: URL) {
        delegate.showInFinder(url: url)
    }
    
    func getXcodeVersion() -> String? {
        return delegate.getXcodeVersion()
    }
    
    func isScanning(_ category: DeveloperDataCategory) -> Bool {
        return categoriesToScan.contains(category)
    }
    
    func toggleScanCategory(_ category: DeveloperDataCategory) {
        if categoriesToScan.contains(category) {
            categoriesToScan.remove(category)
        } else {
            categoriesToScan.insert(category)
        }
    }
    
    func setPurgeInfo() {
        confirmPurgeInfo = .init(
            title: "Are you sure you want to purge?",
            itemType: "Item",
            itemCount: totalSelectedCount,
            purgableMemory: totalSelectedSize,
            details: ["Items are moved to the trash bin, they are NOT deleted.", "In order to regain the memory, you still need to empty your trash bin."],
            buttonText: "Let the Purge begin!"
        )
    }
    
    func startScan() {
        guard !categoriesToScan.isEmpty else {
            return
        }
        
        Task {
            await loadData()
            await finishScan()
        }
    }
}


// MARK: - ScanResultDelegate
extension SharedDeveloperDataENV: ScanResultDelegate {
    var scannedCategories: [ScannedDeveloperCategoryInfo] {
        return categoriesToScan.map {
            return .init(category: $0, size: getSize(for: $0), selectedSize: getSize(for: $0, forSelected: true))
        }
        .sorted(by: { $0.name < $1.name })
    }
}


// MARK: - PurgeContentDelegate
extension SharedDeveloperDataENV: PurgeContentDelegate {
    var hidePurgeCount: Bool {
        return true
    }
    
    var canShowPurgeButtonView: Bool {
        return selectedCategory == nil
    }
    
    func startPurge(progressDelegate: ProgressInfoDelegate?) async throws -> PurgeRecord? {
        let items = getAllSelectedItems()
        let result = try await delegate.purgeItems(items, progressDelegate: progressDelegate)
        
        switch result {
        case .practiceResult:
            return nil
        case .liveResult(let info):
            await removeDeletedItems(nonDeletedIds: info.failureIdList)
            
            return info.record
        }
    }
}


// MARK: - DeviceSupportDelegate
extension SharedDeveloperDataENV: DeviceSupportDelegate {
    func loadDeviceInfoList() async throws -> [DeviceBasicInfo] {
        return try await delegate.loadDeviceInfoList()
    }
}


// MARK: - Private Methods
private extension SharedDeveloperDataENV {
    func getAllSelectedItems() -> [any PurgableItem] {
        return archiveDataSource.selectedItemArray + derivedDataSource.selectedItemArray + docCacheDataSource.selectedItemArray + deviceSupportDatasource.selectedItemArray
    }
    
    func loadData() async {
        for category in categoriesToScan.sorted(by: { $0.name < $1.name }) {
            await setCategoryBeingScanned(category)
            
            do {
                switch category {
                case .archives:
                    let list = try await delegate.loadArchives(progressDelegate: loadProgressDatasource)
                    
                    await setArchives(list)
                case .derivedData:
                    let list = try await delegate.loadDerivedData(progressDelegate: loadProgressDatasource)
                    
                    await setDerivedData(list)
                case .documentationCache:
                    let list = try await delegate.loadDocumentationCacheList(progressDelegate: loadProgressDatasource)
                    
                    await setDocCacheList(list)
                case .deviceSupport:
                    let list = try await delegate.loadDeviceSupportFolders(progressDelegate: loadProgressDatasource)
                    
                    await setDeviceSupport(iOSList: list)
                }
            } catch {
                if let devError = error as? DeveloperDataError {
                    await setCategoryError(category: category, error: devError)
                } else {
                    await setCategoryError(category: category, error: .other(error.localizedDescription))
                }
            }
        }
    }
    
    /// Retrieves the total or selected size for a category.
    ///
    /// - Parameters:
    ///   - category: The category to get the size for.
    ///   - forSelected: Whether to retrieve the size for selected items. Default is `false`.
    /// - Returns: The size of the category's items.
    func getSize(for category: DeveloperDataCategory, forSelected: Bool = false) -> Int64 {
        switch category {
        case .archives:
            return forSelected ? archiveDataSource.selectedSize : archiveDataSource.totalSize
        case .derivedData:
            return forSelected ? derivedDataSource.selectedSize : derivedDataSource.totalSize
        case .documentationCache:
            return forSelected ? docCacheDataSource.selectedSize : docCacheDataSource.totalSize
        case .deviceSupport:
            return forSelected ? deviceSupportDatasource.selectedSize : deviceSupportDatasource.totalSize
        }
    }
}


// MARK: - MainActor
@MainActor
private extension SharedDeveloperDataENV {
    /// Marks the scan as finished.
    func finishScan() {
        scanState = .finished
    }
    
    func setCategoryBeingScanned(_ category: DeveloperDataCategory) {
        currentCategoryBeingScanned = category
    }
    
    func setCategoryError(category: DeveloperDataCategory, error: DeveloperDataError) {
        categoryErrors[category] = error
    }
    
    /// Sets the archive data source with the provided list.
    ///
    /// - Parameter archives: The list of archive folders.
    func setArchives(_ archives: [ArchivePurgeFolder]) {
        archiveDataSource.list = archives
    }
    
    /// Sets the derived data source with the provided list.
    ///
    /// - Parameter list: The list of derived data folders.
    func setDerivedData(_ list: [DerivedDataFolder]) {
        derivedDataSource.list = list
    }
    
    /// Sets the documentation cache data source with the provided list.
    ///
    /// - Parameter list: The list of documentation folders.
    func setDocCacheList(_ list: [DocumentationFolder]) {
        docCacheDataSource.list = list
    }
    
    /// Sets the device support data source with the provided list.
    ///
    /// - Parameter list: The list of device support folders.
    func setDeviceSupport(iOSList: [DeviceSupportFolder]) {
        deviceSupportDatasource.list = iOSList
    }
    
    /// Removes deleted items from all data sources.
    ///
    /// - Parameter nonDeletedIds: The IDs of items that were not deleted. Default is an empty array.
    func removeDeletedItems(nonDeletedIds: [String] = []) {
        archiveDataSource.removeItemsFromAllLists(idList: archiveDataSource.getSelectedItemIds(excludingIds: nonDeletedIds))
        derivedDataSource.removeItemsFromAllLists(idList: derivedDataSource.getSelectedItemIds(excludingIds: nonDeletedIds))
        docCacheDataSource.removeItemsFromAllLists(idList: docCacheDataSource.getSelectedItemIds(excludingIds: nonDeletedIds))
        deviceSupportDatasource.removeItemsFromAllLists(idList: deviceSupportDatasource.getSelectedItemIds(excludingIds: nonDeletedIds))
    }
}


// MARK: - Dependencies
/// A protocol defining the actions required to manage developer data categories,
/// including archives, derived data, and documentation cache.
public protocol DeveloperDataDelegate: PurgeDelegate, DeviceSupportDelegate {
    func showInFinder(url: URL)
    func getXcodeVersion() -> String?
    func loadArchives(progressDelegate: ProgressInfoDelegate) async throws -> [ArchivePurgeFolder]
    func loadDerivedData(progressDelegate: ProgressInfoDelegate) async throws -> [DerivedDataFolder]
    func loadDeviceSupportFolders(progressDelegate: ProgressInfoDelegate) async throws -> [DeviceSupportFolder]
    func loadDocumentationCacheList(progressDelegate: ProgressInfoDelegate) async throws -> [DocumentationFolder]
}

public enum DeveloperDataError: Error {
    case emptyPath
    case missingFolder
    case other(String)
}

extension DeveloperDataError {
    var message: String {
        switch self {
        case .emptyPath:
            return "Looks like there was a problem with the path to this category. Reset permissions from Settings and try again if you keep getting this error."
        case .missingFolder:
            return "You don't have anything to clean for this category!"
        case .other(let message):
            return "Something went wrong. Please reset permissions from settings and try again. Error: \(message)"
        }
    }
}
