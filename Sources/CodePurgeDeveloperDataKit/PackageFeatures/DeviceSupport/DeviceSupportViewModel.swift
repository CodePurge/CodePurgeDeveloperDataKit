//
//  DeviceSupportViewModel.swift
//
//
//  Created by Nikolai Nobadi on 1/4/25.
//

import Foundation
import CodePurgeKit

/// A view model responsible for managing device support folders.
///
/// This view model tracks used and unused device support folders, provides selection functionality,
/// and determines which device support files are actively used by recently connected devices.
final class DeviceSupportViewModel: BasePurgeObservableObject<DeviceSupportFolder> {
    @Published var progressInfo: ProgressInfo?
    @Published var recentDeviceInfoList: [DeviceBasicInfo] = []
    @Published var usedDeviceSupport: [DeviceSupportFolder] = []
    @Published var unusedDeviceSupport: [DeviceSupportFolder] = []
    @Published private var allDeviceSupport: [DeviceSupportFolder] = []
    
    private let delegate: DeviceSupportDelegate
    private let loadingDelegate: ProgressInfoDatasource
    private let datasource: PurgableItemDataSource<DeviceSupportFolder>
    
    let error: DeveloperDataError?
    
    /// Initializes the view model with a delegate and data source.
    ///
    /// - Parameters:
    ///   - delegate: The delegate responsible for fetching device support data.
    ///   - datasource: The data source for managing device support folders.
    init(delegate: DeviceSupportDelegate, error: DeveloperDataError?, datasource: PurgableItemDataSource<DeviceSupportFolder>) {
        self.error = error
        self.delegate = delegate
        self.datasource = datasource
        self.loadingDelegate = .init()
        super.init(datasource: datasource)
        
        loadingDelegate.$progressInfo.assign(to: &$progressInfo)
        
        datasource.$list
            .combineLatest($recentDeviceInfoList)
            .map { list, deviceInfoList in
                return list.map({ $0.addDeviceNames(deviceInfoList) })
            }
            .assign(to: &$allDeviceSupport)
        
        $allDeviceSupport
            .map { list in
                return list.filter({ !$0.usedDeviceNameList.isEmpty })
            }
            .assign(to: &$usedDeviceSupport)
        
        $allDeviceSupport
            .map { list in
                return list.filter({ $0.usedDeviceNameList.isEmpty })
            }
            .assign(to: &$unusedDeviceSupport)
    }
}


// MARK: - Display Data
extension DeviceSupportViewModel {
    var selectedCount: Int {
        return datasource.selectedItems.count
    }
    
    var didLoadUsedDeviceSupport: Bool {
        return !usedDeviceSupport.isEmpty
    }
}


// MARK: - Actions
extension DeviceSupportViewModel {
    func selectUnused() {
        toggleAllItems(unusedDeviceSupport)
    }
    
    /// Initiates a scan to determine which device support folders are actively used.
    func determineUsedDeviceSupport() {
        loadingDelegate.updateProgress(.init(details: "Scanning for recently used devices", currentProgress: 0, totalProgress: 0))
        Task {
            do {
                let infoList = try await delegate.loadDeviceInfoList()
                
                await setDeviceInfoList(infoList)
            } catch {
                // TODO: -
                print("failed to load info list")
            }
            
            await finishLoading()
        }
    }
}


// MARK: - MainActor
@MainActor
private extension DeviceSupportViewModel {
    func setDeviceInfoList(_ list: [DeviceBasicInfo]) {
        recentDeviceInfoList = list
    }
    
    func finishLoading() {
        loadingDelegate.progressInfo = nil
    }
}


// MARK: - Dependencies
public protocol DeviceSupportDelegate {
    func loadDeviceInfoList() async throws -> [DeviceBasicInfo]
}


// MARK: - Extension Dependencies
fileprivate extension DeviceSupportFolder {
    func addDeviceNames(_ infoList: [DeviceBasicInfo]) -> DeviceSupportFolder {
        var updated = self
        updated.usedDeviceNameList = infoList.filter({ $0.supportBuildNum == buildNumber && $0.model == modelCode }).map({ $0.name })
        return updated
    }
}
