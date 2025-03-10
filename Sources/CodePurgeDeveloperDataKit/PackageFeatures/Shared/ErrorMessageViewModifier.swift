//
//  ErrorMessageViewModifier.swift
//
//
//  Created by Nikolai Nobadi on 3/10/25.
//

import SwiftUI

struct ErrorMessageViewModifier: ViewModifier {
    let error: DeveloperDataError?
    
    func body(content: Content) -> some View {
        if let error {
            VStack {
                Text(error.message)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            content
        }
    }
}

extension View {
    func showingErrorMessage(_ error: DeveloperDataError?) -> some View {
        modifier(ErrorMessageViewModifier(error: error))
    }
}
