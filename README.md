# CRAVE 🍒 MVP — Modern Cravings Management App

**CRAVE** is an iOS application built with **SwiftUI** and **SwiftData**, helping you track and manage your cravings through a clean, intuitive interface. Whether it’s late-night snacks or midday munchies, CRAVE ensures you stay in control.

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
---
📄 YC MVP Planning Document → https://docs.google.com/document/d/1kcK9C_-ynso44XMNej9MHrC_cZi7T8DXjF1hICOXOD4/edit?tab=t.0

# CRAVE - A Next-Gen Craving Tracker

Welcome to **CRAVE** – a cutting-edge app built with SwiftData & SwiftUI. Check out the architecture and flow diagrams below.

---

## Architecture

<img src="https://github.com/The-Obstacle-Is-The-Way/CRAVE/blob/main/CRAVEApp/Docs/Images/crave-architecture.png" alt="CRAVE Architecture" width="800"/>

---

## Logging Flow

<img src="https://github.com/The-Obstacle-Is-The-Way/CRAVE/blob/main/CRAVEApp/Docs/Images/crave-logging-flow.png" alt="CRAVE Logging Flow" width="800"/>

---

## Navigation States

<img src="https://github.com/The-Obstacle-Is-The-Way/CRAVE/blob/main/CRAVEApp/Docs/Images/crave-navigation-states.png" alt="CRAVE Navigation States" width="800"/>

---

*This MVP has a solid MVVM foundation, and I'm in the process of pivoting to find a technical cofounder for YC. Once that's secured, I'll revisit and refine the code further.*

## 🌟 Architecture & Features

### Data Layer
- **SwiftData Integration**: Harnesses `@Model` for modern persistence and efficient CRUD operations.  
- **Soft Deletions**: Archives cravings instead of fully removing them, preserving data for potential analytics.  
- **Data Manager**: A dedicated `CravingManager` ensures thread-safe data access and state consistency.

### Design System
- **Centralized Tokens**: Unified colors, typography, and spacing for a polished, cohesive design.  
- **Reusable Components**: Custom buttons, text editors, and haptic feedback helpers.  
- **Adaptive Layout**: Responsive UI that looks great on various iOS screens.

### Core Features
- **Quick Logging**: Rapid craving entry with instant persistence.  
- **Smart History**: Cravings are grouped by date, with friendly placeholders if no data exists.  
- **Easy Management**: Swipe-to-archive, bulk edits, and other intuitive actions keep your list tidy.

### Technical Excellence
- **MVVM Architecture**: Leverages `@Observable` for clean, scalable state management.  
- **Comprehensive Testing**: Unit tests, UI tests, and ephemeral in-memory data configurations using XCTest.  
- **Performance Focus**: Swift animations, minimal overhead, and optimized data fetches keep the app smooth.

---

## 🚀 Roadmap
- **iCloud Sync**: Seamless multi-device experience.  
- **AI Insights**: Pattern recognition to identify triggers and trends.  
- **Apple Watch App**: Log cravings and check history right from your wrist.  
- **Home Screen Widgets**: Quick glance at your cravings and progress.  
- **Smart Notifications**: Timely nudges when cravings typically strike.

---

## ⚙️ Development

Built with:
- **SwiftUI**  
- **SwiftData**  
- **Combine**  
- **XCTest**

**Requirements**:
- iOS 17.0+  
- Xcode 15.0+

### Setup & Installation
1. **Clone the repository**:  
   ```bash
   git clone https://github.com/YOUR_USERNAME/CRAVE.git
   cd CRAVE
   ```
2. **Open in Xcode**:  
   Double-click `CRAVE.xcodeproj` or open it via `File > Open...`
3. **Run the project**:  
   Select a simulator or device, then press <kbd>Cmd</kbd> + <kbd>R</kbd>.
4. *(Optional)* **Run Tests**:  
   <kbd>Cmd</kbd> + <kbd>U</kbd> to execute unit and UI tests.

---

## 🤝 Contributing
1. **Fork** this repository  
2. **Create a new branch**:  
   ```bash
   git checkout -b feature-branch
   ```
3. **Commit your changes**:  
   ```bash
   git commit -m "Add new feature"
   ```
4. **Push the branch**:  
   ```bash
   git push origin feature-branch
   ```
5. **Submit a Pull Request** describing your changes.  
   
For issues, feature requests, or ideas, please [open an issue](https://github.com/YOUR_USERNAME/CRAVE/issues).

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).

---

> **CRAVE**: Because understanding your cravings **shouldn’t** be complicated. 🍫  
