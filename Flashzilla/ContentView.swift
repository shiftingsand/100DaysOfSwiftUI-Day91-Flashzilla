//
//  ContentView.swift
//  Flashzilla
//
//  Created by Chris Wu on 7/8/20.
//  Copyright © 2020 Chris Wu. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("hello world ")
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { time in
                print("moving to the background")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
