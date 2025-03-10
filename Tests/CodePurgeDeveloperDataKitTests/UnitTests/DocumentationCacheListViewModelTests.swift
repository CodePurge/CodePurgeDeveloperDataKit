//
//  DocumentationCacheListViewModelTests.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import XCTest
import NnTestHelpers
@testable import CodePurgeDeveloperDataKit

final class DocumentationCacheListViewModelTests: XCTestCase {
    func test_no_current_doc_version_when_xcode_version_is_nil() {
        let sut = makeSUT(xcodeVersion: nil)
        
        XCTAssertNil(sut.currentDocVersion)
    }
    
    func test_no_current_doc_version_when_no_folder_in_list_contains_xcode_version() {
        let folder = makeDocCacheFolder(name: .previousXcodeVersionNumber)
        let sut = makeSUT(xcodeVersion: .currentXcodeVersionNumber, list: [folder])
        
        XCTAssertNil(sut.currentDocVersion)
    }
    
    func test_current_doc_version_exists_when_folder_in_list_matches_xcode_version() {
        let folder = makeDocCacheFolder(name: .currentXcodeVersionNumber)
        let sut = makeSUT(xcodeVersion: .currentXcodeVersionNumber, list: [folder])
        
        assertPropertyEquality(sut.currentDocVersion?.name, expectedProperty: .currentXcodeVersionNumber)
    }
    
    func test_no_older_doc_version_when_list_is_empty() {
        let sut = makeSUT(xcodeVersion: .currentXcodeVersionNumber, list: [])
        
        XCTAssert(sut.olderDocVersions.isEmpty)
    }
    
    func test_all_folders_are_displayed_when_no_current_doc_version_exists() {
        let firstFolder = makeDocCacheFolder(id: "1", name: .oldXcodeVersionNumber)
        let secondFolder = makeDocCacheFolder(id: "2", name: .previousXcodeVersionNumber)
        let sut = makeSUT(xcodeVersion: .currentXcodeVersionNumber, list: [firstFolder, secondFolder])
        
        XCTAssertEqual(sut.olderDocVersions.count, 2)
        assertArray(sut.olderDocVersions, contains: [firstFolder, secondFolder])
    }
    
    func test_older_doc_versions_do_not_contain_current_doc_version_when_it_exists() {
        let currentFolder = makeDocCacheFolder(id: "1", name: .currentXcodeVersionNumber)
        let olderFolder = makeDocCacheFolder(id: "2", name: .oldXcodeVersionNumber)
        let sut = makeSUT(xcodeVersion: .currentXcodeVersionNumber, list: [currentFolder, olderFolder])
        
        XCTAssertEqual(sut.olderDocVersions.count, 1)
        assertPropertyEquality(sut.olderDocVersions.first?.id, expectedProperty: olderFolder.id)
    }
}


// MARK: - SUT
extension DocumentationCacheListViewModelTests {
    func makeSUT(xcodeVersion: String? = nil, list: [DocumentationFolder] = [], file: StaticString = #filePath, line: UInt = #line) -> DocumentationCacheListViewModel {
        let sut = DocumentationCacheListViewModel(xcodeVersion: xcodeVersion, error: nil, datasource: .init(list: list))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
