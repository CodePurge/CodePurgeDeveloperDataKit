//
//  XCTestCase+Extensions.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import XCTest
import CodePurgeDeveloperDataKit

extension XCTestCase {
    func makeArchiveFolder(id: String = "0", url: URL? = nil, name: String = "MyProjectArchive", size: Int64 = 100, creationDate: Date? = nil, dateModified: Date? = nil) -> ArchivePurgeFolder {
        return .init(id: id, url: url, name: name, size: size, imageData: nil, creationDate: creationDate, dateModified: dateModified, versionNumber: nil, uploadStatus: nil)
    }
    
    func makeDerivedDataFolder(id: String = "0", name: String = "MyProject", size: Int64 = 100, dateModified: Date? = nil) -> DerivedDataFolder {
        return .init(id: id, url: nil, name: name, size: size, dateModified: dateModified)
    }
    
    func makeDeviceSupport(id: String = "0", name: String = "iOS 17", size: Int64 = 100, modelCode: String = "", buildNumber: String = "", dateModified: Date? = nil) -> DeviceSupportFolder {
        return .init(id: id, url: nil, name: name, size: size, dateModified: dateModified, modelCode: modelCode, buildNumber: buildNumber, usedDeviceNameList: [])
    }
    
    func makeDocCacheFolder(id: String = "0", name: String = .oldXcodeVersionNumber, size: Int64 = 100) -> DocumentationFolder {
        return .init(id: id, url: nil, name: name, size: size, dateModified: nil, parentFolderName: "")
    }
}


// MARK: - Extension Dependencies
extension String {
    static var oldXcodeVersionNumber: String {
        return "13.4.1"
    }
    
    static var previousXcodeVersionNumber: String {
        return "14.1.0"
    }
    
    static var currentXcodeVersionNumber: String {
        return "15.1.0"
    }
}
