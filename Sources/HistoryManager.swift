import Cocoa
import Combine

class HistoryManager: ObservableObject {
    static let maxItems = 100
    static let ttl: TimeInterval = 3600

    @Published var items: [ClipboardItem] = []

    private var lastChangeCount: Int
    private var lastCopiedText: String
    private var monitorTimer: Timer?
    private var cleanupTimer: Timer?

    private let storageKey = "clipboard_history"

    init() {
        let pasteboard = NSPasteboard.general
        lastChangeCount = pasteboard.changeCount
        lastCopiedText = pasteboard.string(forType: .string) ?? ""
        load()
        expireOldItems()
        DispatchQueue.main.async { [self] in
            startMonitoring()
            startCleanup()
        }
    }

    func startMonitoring() {
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.check()
        }
    }

    func startCleanup() {
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.expireOldItems()
        }
    }

    func stop() {
        monitorTimer?.invalidate()
        monitorTimer = nil
        cleanupTimer?.invalidate()
        cleanupTimer = nil
    }

    private func expireOldItems() {
        let cutoff = Date().addingTimeInterval(-Self.ttl)
        let before = items.count
        items.removeAll { !$0.isPinned && $0.timestamp < cutoff }
        if items.count != before {
            DispatchQueue.main.async { [self] in save() }
        }
    }

    private func check() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        guard let text = pasteboard.string(forType: .string) else { return }
        guard text != lastCopiedText else { return }
        lastCopiedText = text

        DispatchQueue.main.async { [self] in
            add(text)
        }
    }

    func add(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let existing = items.firstIndex(where: { $0.text == trimmed }) {
            items.remove(at: existing)
        }

        let item = ClipboardItem(text: trimmed)
        items.insert(item, at: 0)

        if items.count > Self.maxItems {
            items = Array(items.prefix(Self.maxItems))
        }

        save()
    }

    func delete(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func clear() {
        items.removeAll()
        save()
    }

    func togglePin(_ item: ClipboardItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isPinned.toggle()

        if items[index].isPinned {
            let pinned = items.remove(at: index)
            items.insert(pinned, at: 0)
        }

        save()
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data)
        else { return }
        items = decoded
    }
}
