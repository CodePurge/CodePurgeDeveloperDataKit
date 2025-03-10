//
//  DeviceSupportViewModelTests.swift
//
//
//  Created by Nikolai Nobadi on 1/28/25.
//

import XCTest
import Combine
import NnTestHelpers
import CodePurgeKit
@testable import CodePurgeDeveloperDataKit

final class DeviceSupportViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        super.tearDown()
    }
}


// MARK: - Unit Tests
extension DeviceSupportViewModelTests {
    func test_starting_values_are_empty() {
        let (sut, datasource) = makeSUT()
        
        XCTAssertNil(sut.progressInfo)
        XCTAssert(sut.usedDeviceSupport.isEmpty)
        XCTAssert(sut.unusedDeviceSupport.isEmpty)
        XCTAssert(sut.recentDeviceInfoList.isEmpty)
        XCTAssert(datasource.list.isEmpty)
        XCTAssert(datasource.selectedItems.isEmpty)
    }
    
    func test_only_shows_used_devices_were_loaded_when_used_devices_is_not_empty() {
        let sut = makeSUT().sut
        
        XCTAssertFalse(sut.didLoadUsedDeviceSupport)
        
        sut.usedDeviceSupport = [makeDeviceSupport()]
        
        XCTAssert(sut.didLoadUsedDeviceSupport)
    }
    
    func test_loads_used_device_info_list_and_updates_progress_info() async {
        let sut = makeSUT().sut
        
        sut.determineUsedDeviceSupport()
        
        waitForCondition(publisher: sut.$progressInfo, cancellables: &cancellables, condition: { $0 != nil })
        
        waitForCondition(publisher: sut.$progressInfo, cancellables: &cancellables, condition: { $0 == nil })
    }
    
    func test_updates_progress_info_when_loading_device_info_throws_an_error() async {
        let sut = makeSUT(throwError: true).sut
        
        sut.determineUsedDeviceSupport()
        
        waitForCondition(publisher: sut.$progressInfo, cancellables: &cancellables, condition: { $0 != nil })
        
        waitForCondition(publisher: sut.$progressInfo, cancellables: &cancellables, condition: { $0 == nil })
    }
    
    func test_only_toggles_selection_of_unused_device_support() {
        let usedSupport = makeDeviceSupport(id: "used")
        let firstUnusedSupport = makeDeviceSupport(id: "firstUnused")
        let secondUnusedSupport = makeDeviceSupport(id: "secondUnused")
        let (sut, datasource) = makeSUT(deviceSupport: [usedSupport, firstUnusedSupport, secondUnusedSupport])
        
        sut.usedDeviceSupport = [usedSupport]
        sut.unusedDeviceSupport = [firstUnusedSupport, secondUnusedSupport]
        
        XCTAssert(datasource.selectedItemArray.isEmpty)
        
        sut.selectUnused()
        
        assertArray(datasource.selectedItemArray, doesNotContain: [usedSupport])
        assertArray(datasource.selectedItemArray, contains: [firstUnusedSupport, secondUnusedSupport])
        
        sut.selectUnused()
        
        XCTAssert(datasource.selectedItemArray.isEmpty)
    }
    
    func test_updates_used_device_support_with_devices_that_contain_loaded_device_info_that_matches_both_model_and_build_number() async {
        let deviceInfo = makeDeviceInfo(name: "iPhone 8", model: "iPhone10,1", buildNum: "12345")
        let usedDeviceSupport = makeDeviceSupport(id: "used", modelCode: deviceInfo.model, buildNumber: deviceInfo.supportBuildNum)
        let firstUnusedSupport = makeDeviceSupport(id: "firstUnused")
        let secondUnusedSupport = makeDeviceSupport(id: "secondUnused", modelCode: deviceInfo.model, buildNumber: "incorrectBuildNumber")
        let thirdUnusedSupport = makeDeviceSupport(id: "thirdUnused", modelCode: "incorrectModel", buildNumber: deviceInfo.supportBuildNum)
        let allUnusedSupport = [firstUnusedSupport, secondUnusedSupport, thirdUnusedSupport]
        let sut = makeSUT(deviceSupport: [usedDeviceSupport] + allUnusedSupport, infoToLoad: [deviceInfo]).sut
        
        sut.determineUsedDeviceSupport()
        
        waitForCondition(publisher: sut.$usedDeviceSupport, cancellables: &cancellables, condition: { !$0.isEmpty })
        
        assertPropertyEquality(sut.usedDeviceSupport.count, expectedProperty: 1)
        assertPropertyEquality(sut.usedDeviceSupport.first?.id, expectedProperty: usedDeviceSupport.id)
        assertPropertyEquality(sut.usedDeviceSupport.first?.id, expectedProperty: usedDeviceSupport.id)
        
        assertPropertyEquality(sut.unusedDeviceSupport.count, expectedProperty: allUnusedSupport.count)
        assertArray(sut.unusedDeviceSupport.map({ $0.id }), contains: allUnusedSupport.map({ $0.id }))
    }
}


// MARK: - SUT
extension DeviceSupportViewModelTests {
    func makeSUT(deviceSupport: [DeviceSupportFolder] = [], infoToLoad: [DeviceBasicInfo] = [], throwError: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (sut: DeviceSupportViewModel, datasource: PurgableItemDataSource<DeviceSupportFolder>) {
        let delegate = DelegateStub(throwError: throwError, infoToLoad: infoToLoad)
        let datasource = PurgableItemDataSource<DeviceSupportFolder>(list: deviceSupport)
        let sut = DeviceSupportViewModel(delegate: delegate, error: nil, datasource: datasource)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(delegate, file: file, line: line)
        trackForMemoryLeaks(datasource, file: file, line: line)
        
        return (sut, datasource)
    }
    
    func makeDeviceInfo(name: String = "", model: String = "", buildNum: String = "") -> DeviceBasicInfo {
        return .init(name: name, model: model, supportBuildNum: buildNum)
    }
}


// MARK: - Helper Classes
extension DeviceSupportViewModelTests {
    class DelegateStub: DeviceSupportDelegate {
        private let throwError: Bool
        private let infoToLoad: [DeviceBasicInfo]
        
        init(throwError: Bool, infoToLoad: [DeviceBasicInfo]) {
            self.throwError = throwError
            self.infoToLoad = infoToLoad
        }
        
        func loadDeviceInfoList() async throws -> [DeviceBasicInfo] {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return infoToLoad
        }
    }
}
