//
//  DocumentationCacheListView.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import SwiftUI
import CodePurgeKit

struct DocumentationCacheListView: View {
    @StateObject var viewModel: DocumentationCacheListViewModel
    
    var body: some View {
        List {
            if let currentDocVersion = viewModel.currentDocVersion {
                Section("Current Version") {
                    DocCacheRow(folder: currentDocVersion)
                }
            }
            
            Section("Older Versions") {
                ForEach(viewModel.olderDocVersions) { folder in
                    DocCacheRow(folder: folder)
                        .withCheckboxSelection(isSelected: viewModel.isSelected(folder)) {
                            viewModel.toggleItem(folder)
                        }
                }
            }
        }
        .roundedList()
        .withSelectionDetailFooter(selectionCount: viewModel.selectedItemCount, selectionSize: viewModel.selectedSize)
        .showingErrorMessage(viewModel.error)
    }
}


// MARK: - Row
fileprivate struct DocCacheRow: View {
    let folder: DocumentationFolder
    
    var body: some View {
        Text("Version \(folder.name)")
            .withTrailingSizeLabel(size: folder.size)
    }
}


// MARK: - Preview
#Preview {
    DocumentationCacheListView(viewModel: .init(xcodeVersion: nil, error: nil, datasource: .init()))
}
