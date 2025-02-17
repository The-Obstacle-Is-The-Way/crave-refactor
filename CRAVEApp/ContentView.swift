//
//  🍒
//  CRAVEApp/ContentView.swift
//  Purpose: The root view container for our entire app
//
//

import SwiftUI    // For building our user interface
import SwiftData  // For database access

// This is our main view - think of it as the first page in our app's story
struct ContentView: View {
    // body tells SwiftUI what to show on the screen
    var body: some View {
        // CRAVETabView() creates our tab bar interface
        // It automatically gets access to our database through SwiftUI's environment
        // Think of it like a magic connection to our app's data
        CRAVETabView() 
    }
}
