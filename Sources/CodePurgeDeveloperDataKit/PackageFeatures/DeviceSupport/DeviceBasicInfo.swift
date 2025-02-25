//
//  DeviceBasicInfo.swift
//  
//
//  Created by Nikolai Nobadi on 1/27/25.
//

/// Represents basic information about a device.
///
/// This struct stores details about a device, including its name, model,
/// and the build number associated with its device support files.
public struct DeviceBasicInfo: Hashable {
    /// The user-friendly name of the device.
    public let name: String
    
    /// The internal model identifier of the device (e.g., "iPhone14,2").
    public let model: String
    
    /// The build number of the iOS version that the device support files correspond to.
    public let supportBuildNum: String

    /// Creates a new instance of `DeviceBasicInfo`.
    ///
    /// - Parameters:
    ///   - name: The user-friendly name of the device.
    ///   - model: The internal model identifier of the device.
    ///   - supportBuildNum: The build number of the device support files.
    public init(name: String, model: String, supportBuildNum: String) {
        self.name = name
        self.model = model
        self.supportBuildNum = supportBuildNum
    }
}

