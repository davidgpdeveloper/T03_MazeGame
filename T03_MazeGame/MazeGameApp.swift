//
//  MazeGameApp.swift
//  T03_MazeGame
//

import SwiftUI

@main
struct MazeGameApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
