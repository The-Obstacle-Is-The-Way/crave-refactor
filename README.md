CRAVE - MVP

Overview
CRAVE is a SwiftData-powered iOS application designed to help users log and track cravings. Built with SwiftUI + SwiftData, CRAVE offers a minimal yet scalable architecture for managing craving entries efficiently.

📄 YC MVP Planning Document → https://docs.google.com/document/d/1kcK9C_-ynso44XMNej9MHrC_cZi7T8DXjF1hICOXOD4/edit?tab=t.0

📂 Project Structure

```bash

CRAVEApp/
├── CRAVE.entitlements
├── Info.plist
├── CRAVEApp.swift
├── ContentView.swift
├── Assets.xcassets/
│
├── Core/
│   ├── DesignSystem/
│   │   ├── CRAVEDesignSystem.swift
│   │   └── Components/
│   │       ├── CraveButton.swift
│   │       └── CraveTextEditor.swift
│   └── Extensions/
│       ├── Date+Formatting.swift
│       └── View+Extensions.swift
│
├── Data/
│   ├── Entities/
│   │   └── CravingModel.swift
│   └── CravingManager.swift
│
├── Screens/
│   ├── LogCraving/
│   │   ├── LogCravingView.swift
│   │   └── LogCravingViewModel.swift
│   ├── DateList/
│   │   ├── DateListView.swift
│   │   └── DateListViewModel.swift
│   └── CravingList/
│       ├── CravingListView.swift
│       └── CravingListViewModel.swift
│
├── Navigation/
│   └── CRAVETabView.swift
│
├── Preview Content/
│   └── Preview Assets.xcassets/
│
└── Tests/
    ├── CRAVETests/
    │   └── CravingManagerTests.swift
    └── CRAVEUITests/
        └── CRAVEUITests.swift

```

🏗 Key Features

1️⃣ SwiftData Model (CravingModel.swift)
Uses @Model for persistence.
Stores craving details (text, timestamp, isDeleted).
Handles data storage and retrieval via CravingManager.swift.

2️⃣ App Structure (CRAVEApp.swift)
Provides SwiftData ModelContainer for dependency injection.
Uses SwiftUI-based navigation with CRAVETabView.swift.

3️⃣ UI Components (CRAVEDesignSystem.swift)
Centralized color, typography, layout, and haptic feedback.
Custom components: CraveButton.swift, CraveTextEditor.swift.

4️⃣ Screens (MVVM Architecture)
✅ Log a Craving (LogCravingView.swift)
Allows users to enter a craving.
Uses LogCravingViewModel.swift for state management.
Calls submitCraving() to persist cravings.

✅ Craving History (DateListView.swift)
Displays cravings grouped by date.
Uses SwiftData’s @Query property wrapper.
Shows an empty state when no cravings exist.

✅ Craving Detail (CravingListView.swift)
Lists cravings for a selected date.
Implements .onDelete {} to remove cravings from SwiftData.

5️⃣ Testing (CRAVETests & CRAVEUITests)
Uses XCTest to validate data persistence & UI flows.
Implements in-memory testing with ModelContainer(.ephemeral).

🚀 Future Enhancements
Cloud Sync (iCloud integration for multi-device support)
AI Insights (Craving patterns & behavioral analysis)
Apple Watch & VisionOS support
Widgets & Notifications for habit reminders

📦 Setup & Installation
Clone the repository:

git clone https://github.com/YOUR_USERNAME/CRAVE.git
cd CRAVE
Open in Xcode:
  Double-click CRAVE.xcodeproj.
Run the project:
  Select a simulator or device and press Cmd + R.
Optional: Run Tests

Cmd + U  # Runs unit tests in Xcode

🌟 Contributing
Fork the repository
Create a new branch: git checkout -b feature-branch-name
Commit changes: git commit -m "Add new feature"
Push to GitHub: git push origin feature-branch-name
Create a Pull Request
For issues, feature requests, or ideas, submit a GitHub Issue!

📄 License
This project is licensed under the MIT License.
🚀 For detailed MVP planning, see: YC MVP Google Doc: https://docs.google.com/document/d/1kcK9C_-ynso44XMNej9MHrC_cZi7T8DXjF1hICOXOD4/edit?tab=t.0
