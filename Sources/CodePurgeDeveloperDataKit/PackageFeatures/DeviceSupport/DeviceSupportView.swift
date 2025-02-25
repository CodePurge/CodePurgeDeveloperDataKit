//
//  DeviceSupportView.swift
//
//
//  Created by Nikolai Nobadi on 1/4/25.
//

import SwiftUI
import CodePurgeKit

struct DeviceSupportView: View {
    @State private var showingConfirmation = false
    @StateObject var viewModel: DeviceSupportViewModel
    
    var body: some View {
        VStack {
            if viewModel.didLoadUsedDeviceSupport {
                Button("Select All Unused Support", action: viewModel.selectUnused)
            }
            
            List {
                Section("Used Device Support") {
                    if viewModel.didLoadUsedDeviceSupport {
                        ForEach(viewModel.usedDeviceSupport) { folder in
                            DeviceSupportRow(folder: folder)
                        }
                    } else {
                        Button("Determine Used Device Support") {
                            showingConfirmation = true
                        }
                    }
                }
                
                Section("Unused Device Support") {
                    ForEach(viewModel.unusedDeviceSupport) { folder in
                        DeviceSupportRow(folder: folder)
                            .withCheckboxSelection(isSelected: viewModel.isSelected(folder)) {
                                viewModel.toggleItem(folder)
                            }
                    }
                }
            }
            .roundedList()
        }
        .withSelectionDetailFooter(selectionCount: viewModel.selectedCount, selectionSize: viewModel.selectedSize)
        .showingLoadingDevicesProgressBar(progress: $viewModel.progressInfo)
        .confirmationDialog("", isPresented: $showingConfirmation) {
            Button("Okay", action: viewModel.determineUsedDeviceSupport)
        } message: {
            Text("DevCodePurge will check for recently used devices for the Xcode app at Applications/Xcode.app\n\nIn the future, you will be able to select the location of the Xcode app that you would like to use.")
        }
    }
}


// MARK: - Row
fileprivate struct DeviceSupportRow: View {
    let folder: DeviceSupportFolder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(folder.name)
                    .font(.headline)
                
                Text(folder.buildNumber)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 400, alignment: .leading)
            
            
            if !folder.usedDeviceNameList.isEmpty {
                VStack(alignment: .leading) {
                    ForEach(folder.usedDeviceNameList, id: \.self) { name in
                        Text(name)
                            .bold()
                            .padding(.vertical, 5)
                            .foregroundStyle(Color.softBlue)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 200, alignment: .leading)
                    }
                }
            }
        }
        .withTrailingSizeLabel(prefix: "", size: folder.size)
    }
}


// MARK: - Preview
#Preview {
    class PreviewDelegate: DeviceSupportDelegate {
        func loadDeviceInfoList() async throws -> [DeviceBasicInfo] { [] }
    }
    
    return DeviceSupportView(viewModel: .init(delegate: PreviewDelegate(), datasource: .init(list: DeviceSupportFolder.sampleList)))
}
