//
//  DerivedDataFeatureView.swift
//  
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import SwiftUI
import CodePurgeKit

struct DerivedDataListView: View {
    @StateObject var viewModel: DerivedDataListViewModel
    
    var body: some View {
        VStack {
            if viewModel.canShowSelectOldFoldersButton {
                Button("Select Old Folders", action: viewModel.selectOldFolders)
            }
            
            List(viewModel.sections) { section in
                Section {
                    ForEach(section.items) { folder in
                        FolderRow(folder: folder)
                            .withCheckboxSelection(isSelected: viewModel.isSelected(folder)) {
                                viewModel.toggleItem(folder)
                            }
                    }
                } header: {
                    ListItemSectionView(section: section, toggleAll: viewModel.toggleSelectAll)
                }
            }
            .roundedList()
        }
        .animation(.smooth, value: viewModel.canShowSelectOldFoldersButton)
        .withSelectionDetailFooter(selectionCount: viewModel.selectedItemCount, selectionSize: viewModel.selectedSize)
        .showingErrorMessage(viewModel.error)
    }
}


// MARK: - Row
fileprivate struct FolderRow: View {
    let folder: DerivedDataFolder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(folder.name)
                .bold()
            
            ShortFormattedDateLabel("Last Date Modified", date: folder.dateModified)
        }
        .withTrailingSizeLabel(prefix: "Size", size: folder.size)
    }
}


// MARK: - Preview
#Preview {
    DerivedDataListView(viewModel: .init(error: nil, datasource: .init()))
}
