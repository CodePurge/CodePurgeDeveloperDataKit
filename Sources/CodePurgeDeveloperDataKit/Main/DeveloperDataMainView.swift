//
//  DeveloperDataMainView.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import SwiftUI
import CodePurgeKit

/// A SwiftUI view that serves as the main interface for managing developer data categories.
///
/// This view allows users to scan and manage various developer data categories, including
/// archives, derived data, and documentation cache. It dynamically updates its content based
/// on the current scan state and user interactions.
public struct DeveloperDataMainView: View {
    @Environment(\.purgeIsLive) private var isLive
    @StateObject var sharedENV: SharedDeveloperDataENV
    
    /// Creates a new instance of `DeveloperDataMainView` with the given delegate.
    ///
    /// - Parameter delegate: A delegate conforming to `DeveloperDataDelegate` for managing developer data actions.
    public init(delegate: DeveloperDataDelegate) {
        self._sharedENV = .init(wrappedValue: .init(delegate: delegate))
    }
    
    public var body: some View {
        ScanContentView(delegate: sharedENV) {
            ScanStartCategoryListView(
                options: DeveloperDataCategory.allCases.sorted(by: { $0.name < $1.name }),
                selections: sharedENV.categoriesToScan,
                toggleScanCategory: sharedENV.toggleScanCategory(_:),
                startScan: sharedENV.startScan
            )
        } result: {
            ScanResultView(selection: $sharedENV.selectedCategory, delegate: sharedENV) { selection in
                switch selection.category {
                case .archives:
                    ArchiveListView(viewModel: .customInit(env: sharedENV))
                case .derivedData:
                    DerivedDataListView(viewModel: .customInit(env: sharedENV))
                case .documentationCache:
                    DocumentationCacheListView(viewModel: .customInit(env: sharedENV))
                case .deviceSupport:
                    DeviceSupportView(viewModel: .customInit(env: sharedENV))
                }
            }
            .showingPurgeContent(purgeInfo: $sharedENV.confirmPurgeInfo, delegate: sharedENV) {
                PurgeButton(selectionCount: sharedENV.totalSelectedCount, action: sharedENV.setPurgeInfo)
            }
        }
        .animation(.smooth(duration: 0.75), value: sharedENV.selectedCategory)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: sharedENV.selectedCategory != nil ? .top : .center)
    }
}


// MARK: - PurgeButton
fileprivate struct PurgeButton: View {
    @Environment(\.purgeIsLive) private var isLive

    let selectionCount: Int
    let action: () -> Void
    
    private var text: String {
        return "Purge \("\(selectionCount)") items"
    }
    
    private var isDisabled: Bool {
        return selectionCount == 0
    }
    
    var body: some View {
        Button(text, action: action)
            .buttonStyle(.rectPurgeStyle(isLive: isLive, disabled: isDisabled))
            .disabled(isDisabled)
    }
}

// MARK: - Preview
#Preview {
    DeveloperDataMainView(delegate: PreviewDeveloperDataDelegate())
}


// MARK: - Extension Dependencies
fileprivate extension ArchiveListViewModel {
    static func customInit(env: SharedDeveloperDataENV) -> ArchiveListViewModel {
        return .init(error: env.categoryErrors[.archives], datasource: env.archiveDataSource, onShowInFinder: env.showInFinder(url:))
    }
}

fileprivate extension DerivedDataListViewModel {
    static func customInit(env: SharedDeveloperDataENV) -> DerivedDataListViewModel {
        return .init(datasource: env.derivedDataSource)
    }
}

fileprivate extension DocumentationCacheListViewModel {
    static func customInit(env: SharedDeveloperDataENV) -> DocumentationCacheListViewModel {
        return .init(xcodeVersion: env.getXcodeVersion(), datasource: env.docCacheDataSource)
    }
}

fileprivate extension DeviceSupportViewModel {
    static func customInit(env: SharedDeveloperDataENV) -> DeviceSupportViewModel {
        return .init(delegate: env, datasource: env.deviceSupportDatasource)
    }
}
