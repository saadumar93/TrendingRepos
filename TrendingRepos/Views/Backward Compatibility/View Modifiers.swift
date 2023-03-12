//
//  ViewModifiers.swift
//  TrendingRepos
//
//  Created by Saad Umar on 3/10/23.
//

import SwiftUI

//MARK: Backward Compatible redaction
public enum RedactionReason {
    case loading
}

/// Custom Redaction to allow iOS 13 to implement redacted(), since default redacted() is only available iOS 14 and up
extension View {
    func redacted(reason: RedactionReason?,_ colorScheme:ColorScheme) -> some View {
        modifier(Redactable_Shimmer(reason: reason, colorScheme: colorScheme))
    }
}
///Shimmer plus redaction combined into one
struct Redactable_Shimmer: ViewModifier {
    let reason: RedactionReason?
    let colorScheme: ColorScheme
    
    @ViewBuilder
    func body(content: Content) -> some View {
        switch reason {
        case .loading:
            content
                .modifier(Loading(colorScheme: colorScheme))
        case nil:
            content
        }
    }
}
///More ViewModifier types can be made following this, such as Privacy, Blurred, NoReason etc
struct Loading: ViewModifier {
    let colorScheme: ColorScheme
    
    func body(content: Content) -> some View {
        content
            .accessibility(label: Text("Placeholder"))
            .opacity(0)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .light ? Color.black.opacity(0.1) : Color.white.opacity(0.1))
                    .padding(.vertical, 4.5)
                    .shimmering()
            )
    }
}

//MARK: iOS Version Compatibiity
///Suggest iOS version upgrade via ViewModifier using and alert based modifier
struct EmphasizeiOSUpgradeModifier: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        content.alert(isPresented: .constant(true)) {
            Alert(
                title: Text("Use the app on iOS 14 & above for better experience")
            )
        }
    }
}
