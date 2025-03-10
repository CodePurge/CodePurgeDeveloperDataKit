//
//  ArchiveListViewModelTests.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import XCTest
import Combine
import NnTestHelpers
import CodePurgeKit
@testable import CodePurgeDeveloperDataKit

final class ArchiveListViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        super.tearDown()
    }
}

// MARK: - Observer Tests
extension ArchiveListViewModelTests {
    func test_starting_values_are_empty() {
        let (sut, _) = makeSUT()
        
        XCTAssertTrue(sut.listItems.isEmpty)
    }
    
    func test_list_items_are_updated_when_collections_change() {
        let firstArchive = makeArchiveFolder(id: "1", name: "ProjectA")
        let secondArchive = makeArchiveFolder(id: "2", name: "ProjectB")
        let (sut, datasource) = makeSUT(list: [firstArchive, secondArchive])
        
        waitForCondition(publisher: sut.$listItems, cancellables: &cancellables, condition: { !$0.isEmpty })
        
        datasource.list.removeAll()
        
        waitForCondition(publisher: sut.$listItems, cancellables: &cancellables, condition: { $0.isEmpty })
    }
    
    func test_collections_group_archives_by_name() {
        let firstProjectName = "FirstProject"
        let secondProjectName = "SecondProject"
        let firstArchive = makeArchiveFolder(id: "1", name: firstProjectName)
        let secondArchive = makeArchiveFolder(id: "2", name: firstProjectName)
        let thirdArchive = makeArchiveFolder(id: "3", name: secondProjectName)
        let (sut, _) = makeSUT(list: [firstArchive, secondArchive, thirdArchive])
        
        waitForCondition(publisher: sut.$listItems, cancellables: &cancellables, condition: { !$0.isEmpty })
        
        assertProperty(sut.listItems.first(where: { $0.id == firstProjectName })) { [unowned self] item in
            switch item.rowData {
            case .section(let collection):
                XCTAssertEqual(collection.name, firstProjectName)
            default:
                XCTFail("unexpected row data")
            }
            
            assertPropertyEquality(item.children?.count, expectedProperty: 2)
        }
        
        assertProperty(sut.listItems.first(where: { $0.id == secondProjectName })) { [unowned self] item in
            switch item.rowData {
            case .section(let collection):
                XCTAssertEqual(collection.name, secondProjectName)
            default:
                XCTFail("unexpected row data")
            }
            
            assertPropertyEquality(item.children?.count, expectedProperty: 1)
        }
    }
}

// MARK: - Action Tests
extension ArchiveListViewModelTests {
    func test_select_old_archives_selects_only_old_archives() {
        let today = Date()
        let oldDate = Date.createDate(day: 1, month: 1, year: 2020)
        let oldArchive = makeArchiveFolder(id: "1", creationDate: oldDate)
        let recentArchive = makeArchiveFolder(id: "2", creationDate: today)
        let noCreationDateArchive = makeArchiveFolder(id: "3")
        let allArchives = [oldArchive, recentArchive, noCreationDateArchive]
        let (sut, datasource) = makeSUT(list: allArchives)
        
        waitForCondition(publisher: sut.$listItems, cancellables: &cancellables, condition: { !$0.isEmpty })
        
        sut.selectOldArchives()
        
        assertArray(datasource.list, contains: allArchives)
        assertArray(Array(datasource.selectedItems), doesNotContain: [recentArchive])
        assertArray(Array(datasource.selectedItems), contains: [oldArchive, noCreationDateArchive])
    }
    
    func test_show_in_finder_calls_delegate_with_correct_url() {
        let url = URL(string: "file:///test/path/")!
        let folder = makeArchiveFolder(id: "1", url: url)
        let delegate = MockDelegate()
        let sut = makeSUT(list: [folder], delegate: delegate).sut
        
        sut.showInFinder(folder)
        
        XCTAssertEqual(delegate.urlToShow, url)
    }
}

// MARK: - SUT
extension ArchiveListViewModelTests {
    func makeSUT(list: [ArchivePurgeFolder] = [], delegate: MockDelegate = .init(), file: StaticString = #filePath, line: UInt = #line) -> (sut: ArchiveListViewModel, datasource: PurgableItemDataSource<ArchivePurgeFolder>) {
        let datasource = makeDatasource(list: list)
        let sut = ArchiveListViewModel(error: nil, datasource: datasource, onShowInFinder: delegate.showInFinder(_:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(datasource, file: file, line: line)
        
        return (sut, datasource)
    }
    
    func makeDatasource(list: [ArchivePurgeFolder]) -> PurgableItemDataSource<ArchivePurgeFolder> {
        return .init(list: list)
    }
}

// MARK: - Helper Classes
extension ArchiveListViewModelTests {
    class MockDelegate {
        private(set) var urlToShow: URL?
        
        func showInFinder(_ url: URL) {
            urlToShow = url
        }
    }
}

// MARK: - Extension Dependencies
extension Date {
    static func createDate(day: Int? = nil, month: Int? = nil, year: Int? = nil) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.day = day ?? components.day
        components.month = month ?? components.month
        components.year = year ?? components.year
        return Calendar.current.date(from: components) ?? Date()
    }
}
