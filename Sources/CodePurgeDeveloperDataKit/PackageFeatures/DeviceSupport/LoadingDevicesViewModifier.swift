//
//  LoadingDevicesViewModifier.swift
//
//
//  Created by Nikolai Nobadi on 1/28/25.
//

import SwiftUI
import CodePurgeKit

struct LoadingDevicesViewModifier: ViewModifier {
    @Binding var progressInfo: ProgressInfo?
    @Environment(\.purgeIsLive) private var isLive
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let progressInfo {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                VStack {
                    ProgressBarView("Device Support Scan", info: progressInfo, barColor: .purgeTint(isLive: isLive))
                    
                    GroupBox {
                        Text(progressInfo.details)
                    }
                    .padding()
                }
                .frame(maxWidth: 500, maxHeight: 500)
                .background(.thinMaterial)
                .roundedList()
            }
        }
    }
}

extension View {
    /// Adds a loading overlay that displays a progress bar when scanning for device support.
    ///
    /// This modifier overlays the view with a semi-transparent background and a progress bar
    /// indicating the scan progress. The appearance of the progress bar is influenced by the
    /// `purgeIsLive` environment key.
    ///
    /// - Parameter progress: A binding to `ProgressInfo?` that determines whether the overlay is shown.
    /// - Returns: A modified view with the loading overlay applied when `progress` is not `nil`.
    func showingLoadingDevicesProgressBar(progress: Binding<ProgressInfo?>) -> some View {
        modifier(LoadingDevicesViewModifier(progressInfo: progress))
    }
}
