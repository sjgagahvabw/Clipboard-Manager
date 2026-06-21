import SwiftUI

@main
struct ClipboardManagerApp: App {
    @StateObject private var history = HistoryManager()

    var body: some Scene {
        MenuBarExtra {
            ContentView(history: history)
        } label: {
            Image(systemName: "doc.on.clipboard")
        }
        .menuBarExtraStyle(.window)
    }
}
