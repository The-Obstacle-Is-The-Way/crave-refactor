//
//  CravingListView.swift
//  CRAVE
//
//  Created by [Your Name] on [Date]
//

import UIKit
import SwiftUI
import SwiftData
import Foundation

struct CravingListView: View {
    let selectedDate: Date
    let cravings: [Craving]

    var body: some View {
        List(cravings, id: \.id) { craving in
            Text(craving.text)
        }
        // Display the selected date at the top
        .navigationTitle(Text(selectedDate, style: .date))
    }
}
