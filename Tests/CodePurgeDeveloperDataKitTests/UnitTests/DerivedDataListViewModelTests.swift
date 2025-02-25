//
//  DerivedDataListViewModelTests.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import XCTest
import Combine
import NnTestHelpers
import CodePurgeKit
@testable import CodePurgeDeveloperDataKit

final class DerivedDataListViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        super.tearDown()
    }
}

// MARK: - Observer Tests
extension DerivedDataListViewModelTests {
    func test_starting_values_are_empty() {
        XCTAssert(makeSUT().sut.sections.isEmpty)
    }
    
    func test_section_is_created_when_items_exist() {
        let folder = makeDerivedDataFolder()
        let sut = makeSUT(list: [folder]).sut
        
        waitForCondition(publisher: sut.$sections, cancellables: &cancellables, condition: { $0.first?.items.count == 1 })
    }
    
    func test_items_are_updated_when_list_in_datasource_changes() {
        let firstFolder = makeDerivedDataFolder(id: "1")
        let secondFolder = makeDerivedDataFolder(id: "2")
        let (sut, datasource) = makeSUT(list: [firstFolder])
        
        waitForCondition(publisher: sut.$sections, cancellables: &cancellables, condition: { $0.first?.items.count == 1 })
        
        datasource.list.append(secondFolder)
        
        waitForCondition(publisher: sut.$sections, cancellables: &cancellables, condition: { $0.first?.items.count == 2 })
    }
}

// MARK: - DisplayData Tests
extension DerivedDataListViewModelTests {
    func test_can_show_select_old_folders_button_when_not_all_items_are_selected_and_old_folders_exist() {
        let firstFolder = makeDerivedDataFolder(id: "1")
        let secondFolder = makeDerivedDataFolder(id: "2")
        let sut = makeSUT(list: [firstFolder, secondFolder]).sut
        
        waitForCondition(publisher: sut.$sections, cancellables: &cancellables, condition: { $0.first?.items.count == 2 })
        
        XCTAssert(sut.canShowSelectOldFoldersButton)
    }
    
    func test_cannot_show_select_old_folders_button_when_no_old_folders_exist() {
        let firstFolder = makeDerivedDataFolder(id: "1", dateModified: .init())
        let secondFolder = makeDerivedDataFolder(id: "2", dateModified: .init())
        let sut = makeSUT(list: [firstFolder, secondFolder]).sut
        
        waitForCondition(publisher: sut.$sections, cancellables: &cancellables, condition: { $0.first?.items.count == 2 })
        
        XCTAssertFalse(sut.canShowSelectOldFoldersButton)
    }
    
    func test_cannot_show_select_old_folders_button_when_all_items_are_selected() {
        let firstFolder = makeDerivedDataFolder(id: "1")
        let secondFolder = makeDerivedDataFolder(id: "2", dateModified: .createDate(year: 2024))
        let (sut, datasource) = makeSUT(list: [firstFolder, secondFolder])
        
        datasource.selectedItems.insert(firstFolder)
        datasource.selectedItems.insert(secondFolder)
        
        waitForCondition(publisher: sut.$sections, cancellables: &cancellables, condition: { $0.first?.items.count == 2 })
        
        XCTAssertFalse(sut.canShowSelectOldFoldersButton)
    }
}

// MARK: - Action Tests
extension DerivedDataListViewModelTests {
    func test_toggles_all_items() {
        let firstFolder = makeDerivedDataFolder(id: "1")
        let secondFolder = makeDerivedDataFolder(id: "2")
        let (sut, datasource) = makeSUT(list: [firstFolder, secondFolder])
        
        sut.toggleSelectAll()
        assertArray(Array(datasource.selectedItems), contains: [firstFolder, secondFolder])
        
        sut.toggleSelectAll()
        assertArray(Array(datasource.selectedItems), doesNotContain: [firstFolder, secondFolder])
    }
    
    func test_selecting_old_folders_only_selects_folders_where_date_modified_is_nil_or_older_than_old_day_value() {
        let firstFolder = makeDerivedDataFolder(id: "1")
        let secondFolder = makeDerivedDataFolder(id: "2", dateModified: .createDate(year: 2024))
        let thirdFolder = makeDerivedDataFolder(id: "3", dateModified: .now)
        let fourthFolder = makeDerivedDataFolder(id: "4", dateModified: .now)
        let (sut, datasource) = makeSUT(list: [firstFolder, secondFolder, thirdFolder, fourthFolder])
        
        waitForCondition(publisher: sut.$sections, cancellables: &cancellables, condition: { $0.first?.items.count == 4 })
        
        XCTAssert(datasource.selectedItems.isEmpty)
        
        sut.selectOldFolders()
        
        waitForCondition(publisher: datasource.$selectedItems, cancellables: &cancellables, condition: { !$0.isEmpty })
        
        assertArray(.init(datasource.selectedItems), contains: [firstFolder, secondFolder])
        assertArray(.init(datasource.selectedItems), doesNotContain: [thirdFolder, fourthFolder])
    }
}


// MARK: - SUT
extension DerivedDataListViewModelTests {
    func makeSUT(list: [DerivedDataFolder] = [], selectedItems: Set<DerivedDataFolder> = [], oldFolderDayValue: Int = 1, file: StaticString = #filePath, line: UInt = #line) -> (sut: DerivedDataListViewModel, datasource: PurgableItemDataSource<DerivedDataFolder>) {
        let datasource = makeDatasource(list: list, selectedItems: selectedItems)
        let sut = DerivedDataListViewModel(oldFolderDayValue: oldFolderDayValue, datasource: datasource)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(datasource, file: file, line: line)
        
        return (sut, datasource)
    }
    
    func makeDatasource(list: [DerivedDataFolder], selectedItems: Set<DerivedDataFolder>) -> PurgableItemDataSource<DerivedDataFolder> {
        return .init(list: list, selectedItems: selectedItems)
    }
}
