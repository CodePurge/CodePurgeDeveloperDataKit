# CodePurgeDeveloperDataKit Documentation

**CodePurgeDeveloperDataKit** is a Swift package that builds upon the foundation provided by `CodePurgeKit` to specifically manage and purge Xcode developer data such as Derived Data, Documentation Cache, Archives, and Device Support files. This package provides utilities, view models, and views to handle these operations efficiently and seamlessly.

## Features

- **Category Management**: Scannable categories for Derived Data, Documentation Cache, Archives, and Device Support.
- **Selection and Purging**: Tools to select old or unnecessary data and purge it.
- **Live Updates**: Use of `Combine` to observe and handle real-time changes in data.
- **Customizable Views**: Reusable views like `DeveloperDataMainView` for integration into apps.
- **Mock Data Support**: Simplified testing with sample data utilities.
- **Dynamic UI State Management**: Environment object for shared state handling across views and components.

## Protocols

### `DeveloperDataDelegate`
Defines the required methods to handle developer data operations, including loading data and performing purge actions.

#### Methods:
```swift
func showInFinder(url: URL)
func getXcodeVersion() -> String?
func loadArchives(progressDelegate: ProgressInfoDelegate) async throws -> [ArchivePurgeFolder]
func loadDerivedData(progressDelegate: ProgressInfoDelegate) async throws -> [DerivedDataFolder]
func loadDocumentationCacheList(progressDelegate: ProgressInfoDelegate) async throws -> [DocumentationFolder]
func loadDeviceSupportFolders(progressDelegate: ProgressInfoDelegate) async throws -> [DeviceSupportFolder]
func purgeItems(_ items: [any PurgableItem], progressDelegate: ProgressInfoDelegate?) async throws -> PurgeResult
```

### Example Implementation:
```swift
final class CustomDeveloperDataDelegate: DeveloperDataDelegate {
    func showInFinder(url: URL) {
        NSWorkspace.shared.open(url)
    }

    func getXcodeVersion() -> String? {
        return "14.3"
    }

    func loadArchives(progressDelegate: ProgressInfoDelegate) async throws -> [ArchivePurgeFolder] {
        return ArchivePurgeFolder.sampleList
    }

    func loadDerivedData(progressDelegate: ProgressInfoDelegate) async throws -> [DerivedDataFolder] {
        return DerivedDataFolder.sampleList
    }

    func loadDocumentationCacheList(progressDelegate: ProgressInfoDelegate) async throws -> [DocumentationFolder] {
        return DocumentationFolder.sampleList
    }

    func loadDeviceSupportFolders(progressDelegate: ProgressInfoDelegate) async throws -> [DeviceSupportFolder] {
        return DeviceSupportFolder.sampleList
    }

    func purgeItems(_ items: [any PurgableItem], progressDelegate: ProgressInfoDelegate?) async throws -> PurgeResult {
        return .practiceResult
    }
}
```

## Key Components

### `DeveloperDataMainView`
The primary view that organizes and displays all developer data categories for scanning and purging.

#### Example Usage:
```swift
struct ContentView: View {
    var body: some View {
        DeveloperDataMainView(delegate: CustomDeveloperDataDelegate())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

### `SharedDeveloperDataENV`
A shared environment object that manages scanning, data sources, and user interactions for developer data categories.

#### Properties:
- `categoriesToScan`: A `Set` of `DeveloperDataCategory` to track selected categories.
- `scanState`: Tracks the current state of the scan.
- `selectedCategory`: The currently selected category for detailed viewing.
- `totalSelectedCount`: The number of selected items across all categories.
- `totalSelectedSize`: The total size of selected items across all categories.

#### Methods:
- `func startScan()`
- `func toggleScanCategory(_ category: DeveloperDataCategory)`
- `func showInFinder(url: URL)`
- `func purgeSelectedItems()`

## Device Support Feature

The **Device Support** feature allows scanning, managing, and purging outdated iOS device support files stored by Xcode. These files are used for debugging on specific iOS versions and can take up significant storage space.

### `DeviceSupportFolder`
Represents a folder that stores debugging files for iOS devices.

#### Properties:
- `id`: Unique identifier for the folder.
- `url`: The file path of the folder.
- `name`: The name of the folder, usually the iOS version it supports.
- `size`: The total size of the folder in bytes.
- `dateModified`: The last modification date of the folder.
- `modelCode`: The device model associated with this support file.
- `buildNumber`: The iOS build number this folder supports.
- `usedDeviceNameList`: A list of device names that have used this support file.

### `DeviceSupportViewModel`
Manages the logic for determining which device support folders are still relevant and which can be removed.

#### Properties:
- `usedDeviceSupport`: List of folders associated with devices still in use.
- `unusedDeviceSupport`: List of folders that are no longer needed.
- `didLoadUsedDeviceSupport`: Boolean indicating whether device support usage has been determined.

#### Methods:
- `func determineUsedDeviceSupport()`: Scans for devices that still need their support files.
- `func selectUnused()`: Selects all unused device support files for purging.

### `DeviceSupportView`
A SwiftUI view for displaying and selecting device support folders.

#### Example:
```swift
DeviceSupportView(viewModel: DeviceSupportViewModel(delegate: CustomDeveloperDataDelegate(), datasource: PurgableItemDataSource<DeviceSupportFolder>()))
```