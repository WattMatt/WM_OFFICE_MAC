# WM Office (Mac)

Native macOS application built with Swift and SwiftUI.

## Architecture
- **Driven by:** `wm-master-spec` (The Brain)
- **Core Logic:** `CableSizingService.swift` implements the standardized engineering rules.
- **Data Sync:** `SyncQueue.swift` handles offline data synchronization using an exponential backoff strategy.

## Setup
1. Open `WMOffice.xcodeproj` or the folder in Xcode.
2. Build target: `My Mac`.
3. Run (Cmd+R).

## Requirements
- Xcode 15+
- macOS 14.0+
