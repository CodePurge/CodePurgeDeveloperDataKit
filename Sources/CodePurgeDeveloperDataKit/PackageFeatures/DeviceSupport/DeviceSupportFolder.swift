//
//  DeviceSupportFolder.swift
//
//
//  Created by Nikolai Nobadi on 1/4/25.
//

import Foundation
import CodePurgeKit

/// Represents a device support folder used by Xcode.
///
/// Xcode stores device support files for debugging and running apps on physical devices.
/// These files contain symbol files required for debugging specific iOS versions.
public struct DeviceSupportFolder: PurgableItem {
    public let id: String
    public let url: URL?
    public let name: String
    public let size: Int64
    public let dateModified: Date?
    public let modelCode: String
    public let buildNumber: String
    public var usedDeviceNameList: [String]
    
    public var type: PurgableItemType {
        return .deviceSupport
    }
    
    /// Initializes a new instance of `DeviceSupportFolder`.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the folder.
    ///   - url: The file URL of the folder.
    ///   - name: The name of the folder.
    ///   - size: The size of the folder in bytes.
    ///   - dateModified: The date the folder was last modified.
    ///   - modelCode: The internal model identifier of the device.
    ///   - buildNumber: The build number of the corresponding iOS version.
    ///   - usedDeviceNameList: A list of device names that have used this folder.
    public init(id: String, url: URL?, name: String, size: Int64, dateModified: Date?, modelCode: String, buildNumber: String, usedDeviceNameList: [String]) {
        self.id = id
        self.url = url
        self.name = name
        self.size = size
        self.dateModified = dateModified
        self.modelCode = modelCode
        self.buildNumber = buildNumber
        self.usedDeviceNameList = usedDeviceNameList
    }
}
