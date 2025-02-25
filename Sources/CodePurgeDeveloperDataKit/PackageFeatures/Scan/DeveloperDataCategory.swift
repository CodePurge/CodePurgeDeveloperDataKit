//
//  DeveloperDataCategory.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import CodePurgeKit

/// An enumeration representing the categories of developer data that can be scanned and purged.
public enum DeveloperDataCategory: CaseIterable {
    case archives
    case derivedData
    case documentationCache
    case deviceSupport
}

// MARK: - ScannableCategory Conformance
extension DeveloperDataCategory: ScannableCategory {
    /// The name of the developer data category.
    public var name: String {
        switch self {
        case .archives: 
            return "Archives"
        case .derivedData: 
            return "Derived Data"
        case .documentationCache:
            return "Documentation Cache"
        case .deviceSupport:
            return "Device Support"
        }
    }
    
    /// A summary of what the developer data category represents.
    public var summary: String {
        switch self {
        case .archives: 
            return "Packaged app builds for distribution (e.g., App Store)."
        case .derivedData: 
            return "Temporary files to improve build times."
        case .documentationCache: 
            return "Locally cached API documentation."
        case .deviceSupport:
            return "Debugging files for physical devices."
        }
    }
    
    /// Detailed information about the developer data category, including guidance and tips for purging.
    public var detailInfo: PurgeCategoryDetailInfo {
        switch self {
        case .archives:
            return .init(
                title: "Archives",
                description: "Archives are packaged app builds used for distribution, such as submission to the App Store or TestFlight.",
                details: [
                    "Located in: ~/Library/Developer/Xcode/Archives/",
                    "Includes compiled app binaries, symbol files, and metadata.",
                    "Used for submitting apps or generating .ipa files for testing."
                ],
                guidance: [
                    "Delete if the archive is outdated or unused.",
                    "Keep if you need to redistribute the app."
                ],
                tips: [
                    "Keep at least one archive for each major release of your app.",
                    "Consider moving older archives to external storage to save disk space."
                ]
            )
        case .derivedData:
            return .init(
                title: "Derived Data",
                description: "Derived Data includes temporary files created by Xcode to improve build times and manage project indexes.",
                details: [
                    "Located in: ~/Library/Developer/Xcode/DerivedData/",
                    "Stores build artifacts, intermediate files, and indexes.",
                    "Clearing Derived Data can resolve build errors and unexpected project behavior."
                ],
                guidance: [
                    "Delete if you’re experiencing build errors or need to free up disk space.",
                    "Keep if the folder size is manageable and you’re actively working on the project."
                ],
                tips: [
                    "Clearing Derived Data can fix issues like stale assets or corrupted indexes.",
                    "Automate periodic cleanup for projects you no longer maintain.",
                    "Use Xcode’s command-line tools to clear Derived Data without opening Xcode."
                ]
            )
        case .documentationCache:
            return .init(
                title: "Documentation Cache",
                description: "The documentation cache contains pre-downloaded Apple API documentation for offline access.",
                details: [
                    "Located in: ~/Library/Developer/Xcode/DocumentationCache/",
                    "Speeds up loading of documentation pages by caching them locally.",
                    "Caches information about Apple APIs for quick access."
                ],
                guidance: [
                    "Delete if the cache is outdated or you don’t need offline documentation.",
                    "Keep if you frequently refer to API documentation offline or have limited internet access."
                ],
                tips: [
                    "Download only the documentation for platforms and SDKs you actively use.",
                    "Regularly clean up old or unused documentation to save space.",
                    "Re-download documentation via Xcode’s Preferences if needed."
                ]
            )
        case .deviceSupport:
            return .init(
                title: "Device Support",
                description: "Device Support files are used by Xcode to debug and run apps on physical devices.",
                details: [
                    "Located in: ~/Library/Developer/Xcode/iOS DeviceSupport/",
                    "Includes symbol files for physical devices connected to Xcode.",
                    "Required for debugging on specific iOS versions."
                ],
                guidance: [
                    "Delete if you no longer debug on devices with older iOS versions.",
                    "Keep if you actively debug on devices requiring these files."
                ],
                tips: [
                    "Consider deleting older device support files for iOS versions you no longer test on.",
                    "If you connect a device requiring deleted files, Xcode will redownload them automatically."
                ]
            )
        }
    }
}
