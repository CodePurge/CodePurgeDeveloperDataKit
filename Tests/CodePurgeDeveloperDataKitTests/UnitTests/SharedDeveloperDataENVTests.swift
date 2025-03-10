//
//  SharedDeveloperDataENVTests.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import XCTest
import Combine
import NnTestHelpers
import CodePurgeKit
@testable import CodePurgeDeveloperDataKit

final class SharedDeveloperDataENVTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        super.tearDown()
    }
}


// MARK: - Initialization Tests
extension SharedDeveloperDataENVTests {
    func test_starting_values_are_correct() {
        let (sut, delegate) = makeSUT()
        
        XCTAssertEqual(delegate.itemsToPurgeCount, 0)
        XCTAssertEqual(sut.scanState, .notStarted)
        XCTAssertEqual(sut.categoriesToScan.count, DeveloperDataCategory.allCases.count)
    }
}


// MARK: - Observer Tests
extension SharedDeveloperDataENVTests {
    func test_selection_size_updates_when_items_are_toggled_in_datasources() {
        let sut = makeSUT().sut
        let archive = makeArchiveFolder(size: 100)
        let docCache = makeDocCacheFolder(size: 200)
        let deviceSupport = makeDeviceSupport(size: 300)
        let derivedData = makeDerivedDataFolder(size: 400)
        let totalSize = archive.size + docCache.size + derivedData.size + deviceSupport.size
        
        sut.archiveDataSource.list = [archive]
        sut.docCacheDataSource.list = [docCache]
        sut.derivedDataSource.list = [derivedData]
        sut.deviceSupportDatasource.list = [deviceSupport]
        sut.archiveDataSource.selectedItems.insert(archive)
        
        waitForCondition(publisher: sut.$totalSelectedSize, cancellables: &cancellables, condition: { $0 == archive.size })
        XCTAssertEqual(sut.scannedCategories.map({ $0.size }).calculateTotalSize(), totalSize)
        XCTAssertEqual(sut.scannedCategories.map({ $0.selectedSize }).calculateTotalSize(), archive.size)
        
        sut.docCacheDataSource.selectedItems.insert(docCache)
        
        waitForCondition(publisher: sut.$totalSelectedSize, cancellables: &cancellables) {
            return $0 == archive.size + docCache.size
        }
        XCTAssertEqual(sut.scannedCategories.map({ $0.size }).calculateTotalSize(), totalSize)
        XCTAssertEqual(sut.scannedCategories.map({ $0.selectedSize }).calculateTotalSize(), archive.size + docCache.size)
        
        sut.derivedDataSource.selectedItems.insert(derivedData)
        
        waitForCondition(publisher: sut.$totalSelectedSize, cancellables: &cancellables) {
            return $0 == (totalSize - deviceSupport.size)
        }
        XCTAssertEqual(sut.scannedCategories.map({ $0.size }).calculateTotalSize(), totalSize)
        XCTAssertEqual(sut.scannedCategories.map({ $0.selectedSize }).calculateTotalSize(), totalSize - deviceSupport.size)
        
        sut.deviceSupportDatasource.selectedItems.insert(deviceSupport)
        
        waitForCondition(publisher: sut.$totalSelectedSize, cancellables: &cancellables) {
            return $0 == totalSize
        }
        XCTAssertEqual(sut.scannedCategories.map({ $0.size }).calculateTotalSize(), totalSize)
        XCTAssertEqual(sut.scannedCategories.map({ $0.selectedSize }).calculateTotalSize(), totalSize)
        
        sut.archiveDataSource.selectedItems = []
        sut.derivedDataSource.selectedItems = []
        sut.docCacheDataSource.selectedItems = []
        sut.deviceSupportDatasource.selectedItems = []
        
        waitForCondition(publisher: sut.$totalSelectedSize, cancellables: &cancellables, condition: { $0 == 0 })
        XCTAssertEqual(sut.scannedCategories.map({ $0.size }).calculateTotalSize(), totalSize)
    }
    
    func test_selected_item_count_updates_when_items_are_toggled_in_datasources() {
        let sut = makeSUT().sut
        let archive = makeArchiveFolder(size: 100)
        let docCache = makeDocCacheFolder(size: 200)
        let deviceSupport = makeDeviceSupport(size: 300)
        let derivedData = makeDerivedDataFolder(size: 400)
        
        sut.archiveDataSource.list = [archive]
        sut.docCacheDataSource.list = [docCache]
        sut.derivedDataSource.list = [derivedData]
        sut.deviceSupportDatasource.list = [deviceSupport]
        sut.archiveDataSource.selectedItems.insert(archive)
        
        waitForCondition(publisher: sut.$totalSelectedCount, cancellables: &cancellables, condition: { $0 == 1 })
        
        sut.docCacheDataSource.selectedItems.insert(docCache)
        
        waitForCondition(publisher: sut.$totalSelectedCount, cancellables: &cancellables, condition: { $0 == 2 })
        
        sut.derivedDataSource.selectedItems.insert(derivedData)
        
        waitForCondition(publisher: sut.$totalSelectedCount, cancellables: &cancellables, condition: { $0 == 3 })
        
        sut.deviceSupportDatasource.selectedItems.insert(deviceSupport)
        
        waitForCondition(publisher: sut.$totalSelectedCount, cancellables: &cancellables, condition: { $0 == 4 })
        
        sut.archiveDataSource.selectedItems = []
        sut.derivedDataSource.selectedItems = []
        sut.docCacheDataSource.selectedItems = []
        sut.deviceSupportDatasource.selectedItems = []
        
        waitForCondition(publisher: sut.$totalSelectedCount, cancellables: &cancellables, condition: { $0 == 0 })
    }
}


// MARK: - DisplayData Tests
extension SharedDeveloperDataENVTests {
    func test_footer_is_shown_after_scan_when_no_categories_are_selected() {
        let (sut, _) = makeSUT()
        
        sut.scanState = .finished
        sut.selectedCategory = nil
        
        XCTAssert(sut.showingPurgeFooter)
    }
    
    func test_footer_is_not_shown_after_scan_when_a_category_is_selected() {
        let (sut, _) = makeSUT()
        
        sut.scanState = .finished
        sut.selectedCategory = .init(category: .archives, size: 0, selectedSize: 0)
        
        XCTAssertFalse(sut.showingPurgeFooter)
    }
    
    func test_footer_is_not_shown_before_scan_has_finished() {
        let (sut, _) = makeSUT()
        
        sut.scanState = .inProgress(.init(category: "", progress: .init(details: "", currentProgress: 0, totalProgress: 0)))
        
        XCTAssertFalse(sut.showingPurgeFooter)
    }
}


// MARK: - Action Tests
extension SharedDeveloperDataENVTests {
    func test_shows_url_in_finder() {
        let url = URL(string: "file:///test/path/")!
        let (sut, delegate) = makeSUT()
        
        sut.showInFinder(url: url)
        
        XCTAssertEqual(delegate.urlToShow, url)
    }
    
    func test_gets_xcode_version() {
        let xcodeVersion = "14.0"
        let (sut, _) = makeSUT(xcodeVersion: xcodeVersion)
        
        XCTAssertEqual(sut.getXcodeVersion(), xcodeVersion)
    }
    
    func test_should_scan_category_when_included_in_scan_list() {
        XCTAssert(makeSUT().sut.isScanning(.archives))
    }
    
    func test_should_not_scan_category_when_it_is_not_in_scan_list() {
        let (sut, _) = makeSUT()
        
        sut.categoriesToScan = []
        
        XCTAssertFalse(sut.isScanning(.archives))
    }
    
    func test_scan_category_is_toggled() {
        let sut = makeSUT().sut
        let categoryToToggle = DeveloperDataCategory.archives
        
        assertArray(.init(sut.categoriesToScan), contains: [categoryToToggle])
        
        sut.toggleScanCategory(categoryToToggle)
        
        assertArray(.init(sut.categoriesToScan), doesNotContain: [categoryToToggle])
        
        sut.toggleScanCategory(categoryToToggle)
        
        assertArray(.init(sut.categoriesToScan), contains: [categoryToToggle])
    }
    
    func test_only_data_from_categories_to_scan_is_loaded_during_scan() {
        let archive = makeArchiveFolder()
        let derivedData = makeDerivedDataFolder()
        let docCache = makeDocCacheFolder()
        let sut = makeSUT(archivesToLoad: [archive], derivedDataToLoad: [derivedData], docCacheFoldersToLoad: [docCache]).sut
        
        sut.categoriesToScan = [.archives, .derivedData]
        sut.startScan()
        
        waitForCondition(publisher: sut.$scanState, cancellables: &cancellables, condition: { $0 == .finished })
        
        XCTAssert(sut.docCacheDataSource.list.isEmpty)
        XCTAssert(sut.deviceSupportDatasource.list.isEmpty)
        XCTAssertFalse(sut.archiveDataSource.list.isEmpty)
        XCTAssertFalse(sut.derivedDataSource.list.isEmpty)
    }
    
    func test_scan_state_remains_unchanged_if_no_categories_are_scanned() {
        let (sut, _) = makeSUT()
        
        sut.categoriesToScan = []
        sut.startScan()
        
        waitForCondition(publisher: sut.$scanState, shouldFailIfConditionIsMet: true, cancellables: &cancellables, timeout: 1, condition: { $0 == .finished })
    }
    
    // TODO: - include test to verify errors thrown are set in categoryErrors
    
    func test_only_items_that_were_successfully_purged_are_removed_from_datasources() async {
        let archive = makeArchiveFolder(id: "0")
        let derivedData = makeDerivedDataFolder(id: "1")
        let docCache = makeDocCacheFolder(id: "2")
        let deviceSupport = makeDeviceSupport(id: "3")
        let sut = makeSUT(purgeResult: .liveResult(.init(record: .init(date: .now, itemInfo: .init(size: 0, count: 0), simulatorInfo: .init(size: 0, count: 0)), failureIdList: [docCache.id]))).sut
        
        sut.archiveDataSource.list = [archive]
        sut.archiveDataSource.selectedItems.insert(archive)
        sut.derivedDataSource.list = [derivedData]
        sut.derivedDataSource.selectedItems.insert(derivedData)
        sut.docCacheDataSource.list = [docCache]
        sut.docCacheDataSource.selectedItems.insert(docCache)
        sut.deviceSupportDatasource.list = [deviceSupport]
        sut.deviceSupportDatasource.selectedItems.insert(deviceSupport)
        
        waitForCondition(publisher: sut.$totalSelectedCount, cancellables: &cancellables, condition: { $0 == 4 })
        
        await asyncAssertNoErrorThrown {
            let _ = try await sut.startPurge(progressDelegate: nil)
        }
        
        waitForCondition(publisher: sut.$totalSelectedCount, cancellables: &cancellables, condition: { $0 == 1 })
        
        XCTAssert(sut.archiveDataSource.list.isEmpty)
        XCTAssert(sut.archiveDataSource.selectedItems.isEmpty)
        XCTAssert(sut.derivedDataSource.list.isEmpty)
        XCTAssert(sut.derivedDataSource.selectedItems.isEmpty)
        XCTAssert(sut.deviceSupportDatasource.list.isEmpty)
        XCTAssert(sut.deviceSupportDatasource.selectedItems.isEmpty)
        XCTAssertFalse(sut.docCacheDataSource.list.isEmpty)
        XCTAssertFalse(sut.docCacheDataSource.selectedItems.isEmpty)
    }
    
    func test_no_items_are_removed_from_datasources_after_practice_purge() async {
        let archive = makeArchiveFolder(id: "0")
        let derivedData = makeDerivedDataFolder(id: "1")
        let docCache = makeDocCacheFolder(id: "2")
        let deviceSupport = makeDeviceSupport(id: "3")
        let sut = makeSUT(purgeResult: .practiceResult).sut
        
        sut.archiveDataSource.list = [archive]
        sut.archiveDataSource.selectedItems.insert(archive)
        sut.derivedDataSource.list = [derivedData]
        sut.derivedDataSource.selectedItems.insert(derivedData)
        sut.docCacheDataSource.list = [docCache]
        sut.docCacheDataSource.selectedItems.insert(docCache)
        sut.deviceSupportDatasource.list = [deviceSupport]
        sut.deviceSupportDatasource.selectedItems.insert(deviceSupport)
        
        waitForCondition(publisher: sut.$totalSelectedCount, cancellables: &cancellables, condition: { $0 == 4 })
        
        await asyncAssertNoErrorThrown {
            let _ = try await sut.startPurge(progressDelegate: nil)
        }
        
        waitForCondition(publisher: sut.$totalSelectedCount, shouldFailIfConditionIsMet: true, cancellables: &cancellables, condition: { $0 == 1 })
        
        XCTAssertFalse(sut.archiveDataSource.list.isEmpty)
        XCTAssertFalse(sut.archiveDataSource.selectedItems.isEmpty)
        XCTAssertFalse(sut.derivedDataSource.list.isEmpty)
        XCTAssertFalse(sut.derivedDataSource.selectedItems.isEmpty)
        XCTAssertFalse(sut.docCacheDataSource.list.isEmpty)
        XCTAssertFalse(sut.docCacheDataSource.selectedItems.isEmpty)
        XCTAssertFalse(sut.deviceSupportDatasource.list.isEmpty)
        XCTAssertFalse(sut.deviceSupportDatasource.selectedItems.isEmpty)
    }
}


// MARK: - SUT
extension SharedDeveloperDataENVTests {
    func makeSUT(xcodeVersion: String? = nil, purgeResult: PurgeResult = .practiceResult, archivesToLoad: [ArchivePurgeFolder] = [], derivedDataToLoad: [DerivedDataFolder] = [], deviceSupportToLoad: [DeviceSupportFolder] = [], docCacheFoldersToLoad: [DocumentationFolder] = [], throwError: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (sut: SharedDeveloperDataENV, delegate: MockDelegate) {
        let delegate = MockDelegate(
            throwError: throwError,
            xcodeVersion: xcodeVersion,
            purgeResult: purgeResult,
            archivesToLoad: archivesToLoad,
            derivedDataToLoad: derivedDataToLoad,
            deviceSupportToLoad: deviceSupportToLoad,
            docCacheFoldersToLoad: docCacheFoldersToLoad
        )
        
        let sut = SharedDeveloperDataENV(delegate: delegate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(delegate, file: file, line: line)
        
        return (sut, delegate)
    }
}


// MARK: - Helper Classes
extension SharedDeveloperDataENVTests {
    class MockDelegate: DeveloperDataDelegate {
        private let throwError: Bool
        private let xcodeVersion: String?
        private let purgeResult: PurgeResult
        private let archivesToLoad: [ArchivePurgeFolder]
        private let derivedDataToLoad: [DerivedDataFolder]
        private let deviceSupportToLoad: [DeviceSupportFolder]
        private let docCacheFoldersToLoad: [DocumentationFolder]
        
        private(set) var urlToShow: URL?
        private(set) var itemsToPurgeCount: Int = 0
        
        init(throwError: Bool, xcodeVersion: String?, purgeResult: PurgeResult, archivesToLoad: [ArchivePurgeFolder], derivedDataToLoad: [DerivedDataFolder], deviceSupportToLoad: [DeviceSupportFolder], docCacheFoldersToLoad: [DocumentationFolder]) {
            self.throwError = throwError
            self.purgeResult = purgeResult
            self.xcodeVersion = xcodeVersion
            self.archivesToLoad = archivesToLoad
            self.derivedDataToLoad = derivedDataToLoad
            self.deviceSupportToLoad = deviceSupportToLoad
            self.docCacheFoldersToLoad = docCacheFoldersToLoad
        }
        
        func showInFinder(url: URL) {
            urlToShow = url
        }
        
        func getXcodeVersion() -> String? {
            return xcodeVersion
        }
        
        func loadDeviceInfoList() async throws -> [DeviceBasicInfo] {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return [] // TODO: - 
        }
        
        func loadArchives(progressDelegate: ProgressInfoDelegate) async throws -> [ArchivePurgeFolder] {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return archivesToLoad
        }
        
        func loadDerivedData(progressDelegate: ProgressInfoDelegate) async throws -> [DerivedDataFolder] {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return derivedDataToLoad
        }
        
        func loadDeviceSupportFolders(progressDelegate: ProgressInfoDelegate) async throws -> [DeviceSupportFolder] {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return deviceSupportToLoad
        }
        
        func loadDocumentationCacheList(progressDelegate: ProgressInfoDelegate) async throws -> [DocumentationFolder] {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return docCacheFoldersToLoad
        }
        
        func purgeItems(_ items: [any PurgableItem], progressDelegate: ProgressInfoDelegate?) async throws -> PurgeResult {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            itemsToPurgeCount = items.count
            
            return purgeResult
        }
    }
}
