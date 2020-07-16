//
//  Settings.swift
//  Flashzilla
//
//  Created by Chris Wu on 7/16/20.
//  Copyright © 2020 Chris Wu. All rights reserved.
//

import SwiftUI

struct Settings: View {
     @Environment(\.presentationMode) var presentationMode
    @Binding var retryFailures : Bool
    var body: some View {
        NavigationView {
            Toggle(isOn: $retryFailures) {
                Text("Retry failures")
            }
            .padding()
            .navigationBarItems(trailing: Button("Done") {
                self.presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(retryFailures: .constant(false))
    }
}
