//
//  ArchiveListView.swift
//
//
//  Created by Nikolai Nobadi on 1/3/25.
//

import SwiftUI
import CodePurgeKit

struct ArchiveListView: View {
    @StateObject var viewModel: ArchiveListViewModel
    
    var body: some View {
        VStack {
            Button("Select Old Archives", action: viewModel.selectOldArchives)
            
            List(viewModel.listItems, children: \.children) { listItem in
                switch listItem.rowData {
                case .section(let section):
                    ListItemSectionView(section: section) {
                        viewModel.toggleAllItems(section.items)
                    }
                case .row(let item):
                    ArchiveRow(item: item) {
                        viewModel.showInFinder(item)
                    }
                    .withCheckboxSelection(isSelected: viewModel.isSelected(item)) {
                        viewModel.toggleItem(item)
                    }
                }
            }
            .roundedList()
        }
        .withSelectionDetailFooter(selectionCount: viewModel.selectedItemCount, selectionSize: viewModel.selectedSize)
    }
}


// MARK: - Row
fileprivate struct ArchiveRow: View {
    let item: ArchivePurgeFolder
    let showInFinder: () -> Void
    
    var body: some View {
        HStack {
            if let imageData = item.imageData, let image = NSImage(data: imageData) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
            }
            
            HStack {
                Text(item.name)
                    .bold()
                    .padding(.horizontal)
                
                ShortFormattedDateLabel(nil, date: item.dateModified)
            }
            .withTrailingSizeLabel(size: item.size)
            .contextMenu {
                Button("Show in Finder", action: showInFinder)
            }
        }
    }
}


// MARK: - Preview
#Preview {
    ArchiveListView(viewModel: .init(datasource: .init(), onShowInFinder: { _ in }))
}
