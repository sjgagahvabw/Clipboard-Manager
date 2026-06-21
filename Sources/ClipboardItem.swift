import Cocoa

struct ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let timestamp: Date
    var isPinned: Bool

    init(text: String) {
        self.id = UUID()
        self.text = text
        self.timestamp = Date()
        self.isPinned = false
    }

    func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
