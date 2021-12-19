//
//  ErrorHandling.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/19/21.
//
//  Code courtesy of https://www.ralfebert.com/swiftui/generic-error-handling/

import SwiftUI

struct ErrorAlert: Identifiable {
    var id = UUID()
    var message: String
    var dismissAction: (() -> Void)?
}

class ErrorHandling: ObservableObject {
    @Published var currentAlert: ErrorAlert?

    func handle(error: Error) {
        currentAlert = ErrorAlert(message: error.localizedDescription)
    }
}

struct HandleErrorsByShowingAlertViewModifier: ViewModifier {
    @StateObject var errorHandling = ErrorHandling()

    func body(content: Content) -> some View {
        content
            .environmentObject(errorHandling)
            // Applying the alert for error handling using a background element
            // is a workaround, if the alert would be applied directly,
            // other .alert modifiers inside of content would not work anymore
            .background(
                EmptyView()
                    .alert(item: $errorHandling.currentAlert) { currentAlert in
                        Alert(
                            title: Text("Error"),
                            message: Text(currentAlert.message),
                            dismissButton: .default(Text("Ok")) {
                                currentAlert.dismissAction?()
                            }
                        )
                    }
            )
    }
}

extension View {
    func withErrorHandling() -> some View {
        modifier(HandleErrorsByShowingAlertViewModifier())
    }
}

struct TryButton<Label>: View where Label: View {
    var action: () throws -> Void
    @ViewBuilder var label: () -> Label
    @EnvironmentObject var errorHandling: ErrorHandling
    
    var body: some View {
        Button(action: {
                do {
                    try action()
                } catch {
                    self.errorHandling.handle(error: error)
                }
            },
            label: label)
    }
}

extension TryButton where Label == Text {
    init(_ titleKey: LocalizedStringKey, action: @escaping () throws -> Void) {
        self.init(action: action, label: { Text(titleKey) })
    }

    init<S>(_ title: S, action: @escaping () throws -> Void) where S: StringProtocol {
        self.init(action: action, label: { Text(title) })
    }
}
