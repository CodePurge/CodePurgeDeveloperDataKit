//
//  PreviewContent.swift
//  
//
//  Created by Nikolai Nobadi on 1/30/25.
//

import Foundation
import CodePurgeKit

final class PreviewDeveloperDataDelegate: DeveloperDataDelegate {
    func showInFinder(url: URL) { }
    func getXcodeVersion() -> String? { nil }
    func loadDeviceInfoList() async throws -> [DeviceBasicInfo] { [] }
    func loadArchives(progressDelegate: ProgressInfoDelegate) async throws -> [ArchivePurgeFolder] { ArchivePurgeFolder.sampleList }
    func loadDerivedData(progressDelegate: ProgressInfoDelegate) async throws -> [DerivedDataFolder] { DerivedDataFolder.sampleList }
    func loadDeviceSupportFolders(progressDelegate: ProgressInfoDelegate) async throws -> [DeviceSupportFolder] { DeviceSupportFolder.sampleList }
    func loadDocumentationCacheList(progressDelegate: ProgressInfoDelegate) async throws -> [DocumentationFolder] { DocumentationFolder.sampleList }
    func purgeItems(_ items: [any PurgableItem], progressDelegate: ProgressInfoDelegate?) async throws -> PurgeResult { .practiceResult }
}

extension ArchivePurgeFolder {
    static var sampleList: [ArchivePurgeFolder] {
        return [
            .new(id: "0", name: "MyFirstApp", size: 100),
            .new(id: "1", name: "SecondApp", size: 326498),
            .new(id: "2", name: "ThirdAppIsTheBest", size: 67498649964)
        ]
    }
    
    static func new(id: String, name: String, size: Int64 = 0, creationDate: Date? = nil, dateModified: Date? = nil, versionNumber: String? = nil, uploadStatus: String? = nil) -> ArchivePurgeFolder {
        return .init(id: id, url: nil, name: name, size: size, imageData: nil, creationDate: creationDate, dateModified: dateModified, versionNumber: versionNumber, uploadStatus: uploadStatus)
    }
}

extension DerivedDataFolder {
    static var sampleList: [DerivedDataFolder] {
        return [
            .new(id: "0", name: "MyFirstApp", size: 100),
            .new(id: "1", name: "SecondApp", size: 326498),
            .new(id: "2", name: "ThirdAppIsTheBest", size: 67498649964)
        ]
    }
    
    static func new(id: String, name: String, size: Int64 = 0) -> DerivedDataFolder {
        return .init(id: id, url: nil, name: name, size: size, dateModified: nil)
    }
}

extension DeviceSupportFolder {
    static var sampleList: [DeviceSupportFolder] {
        return [
            .init(id: "0", url: nil, name: "iPhone 8", size: .baseSimulatorSize * 50, dateModified: nil, modelCode: "iPhone7,3", buildNumber: "21G93", usedDeviceNameList: ["Nelix"]),
            .init(id: "1", url: nil, name: "iPad Pro 12.9-inch (4th generation)", size: .baseSimulatorSize * 50, dateModified: nil, modelCode: "iPad7,2", buildNumber: "22B91", usedDeviceNameList: ["Emily's iPad LLU"])
        ]
    }
}

extension DocumentationFolder {
    static var sampleList: [DocumentationFolder] {
        return [
            .new(id: "0", name: "MyFirstApp", size: 100),
            .new(id: "1", name: "SecondApp", size: 326498),
            .new(id: "2", name: "ThirdAppIsTheBest", size: 67498649964)
        ]
    }
    
    static func new(id: String, name: String, size: Int64 = 0) -> DocumentationFolder {
        return .init(id: id, url: nil, name: name, size: size, dateModified: nil, parentFolderName: "")
    }
}
