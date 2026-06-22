import SwiftUI

let accentGradient = LinearGradient(
    colors: [.blue, .purple],
    startPoint: .leading,
    endPoint: .trailing
)

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var state: NSVisualEffectView.State = .followsWindowActiveState

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = material
        v.blendingMode = blendingMode
        v.state = state
        return v
    }

    func updateNSView(_ v: NSVisualEffectView, context: Context) {
        v.material = material
        v.blendingMode = blendingMode
        v.state = state
    }
}

struct ContentView: View {
    @ObservedObject var history: HistoryManager
    @State private var searchText = ""
    @State private var copiedItemId: UUID?

    private var filtered: [ClipboardItem] {
        let sorted = history.items.sorted {
            if $0.isPinned != $1.isPinned { return $0.isPinned && !$1.isPinned }
            if $0.isPinned { return $0.timestamp > $1.timestamp }
            return $0.timestamp > $1.timestamp
        }
        if searchText.isEmpty { return sorted }
        return sorted.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Divider().opacity(0.3)
                searchBar
                Divider().opacity(0.3)
                itemList
                Divider().opacity(0.3)
                footer
            }
        }
        .frame(width: 380, height: 495)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var header: some View {
        HStack {
            Text("Clipboard")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(accentGradient)
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                Text("1h auto-clean")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color.secondary.opacity(0.1)))
            if !history.items.isEmpty {
                Text("\(history.items.count)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.secondary.opacity(0.15)))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var searchBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            TextField("Search...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.primary.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var itemList: some View {
        if history.items.isEmpty {
            emptyState
        } else {
            listContent
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            ZStack {
                Circle()
                    .fill(accentGradient.opacity(0.1))
                    .frame(width: 64, height: 64)
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 26, weight: .regular))
                    .foregroundStyle(accentGradient)
            }
            VStack(spacing: 4) {
                Text("Nothing copied yet")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                Text("Select any text and press Cmd+C")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity)
    }

    private var footer: some View {
        HStack {
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "power")
                        .font(.system(size: 9))
                    Text("Quit")
                        .font(.system(size: 10))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.red.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color.red.opacity(0.15), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .help("Quit Clipboard Manager")
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    private var listContent: some View {
        ScrollView {
            LazyVStack(spacing: 3) {
                ForEach(filtered) { item in
                    ItemRow(
                        item: item,
                        isCopied: copiedItemId == item.id
                    ) {
                        item.copyToClipboard()
                        withAnimation(.spring(response: 0.3)) {
                            copiedItemId = item.id
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation {
                                if copiedItemId == item.id { copiedItemId = nil }
                            }
                        }
                    } onPin: {
                        withAnimation(.spring(response: 0.3)) {
                            history.togglePin(item)
                        }
                    } onDelete: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            history.delete(item)
                        }
                    }
                }
            }
            .padding(8)
        }
    }
}

struct ItemRow: View {
    let item: ClipboardItem
    let isCopied: Bool
    let onCopy: () -> Void
    let onPin: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            pinArea
            contentArea
            Spacer(minLength: 4)
            timeBadge
            if isHovered { actions }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(overlayBorder)
        .contentShape(Rectangle())
        .onTapGesture(perform: onCopy)
        .onHover { isHovered = $0 }
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.95)),
            removal: .opacity.combined(with: .move(edge: .leading))
        ))
    }

    @ViewBuilder
    private var pinArea: some View {
        if item.isPinned {
            Image(systemName: "pin.fill")
                .font(.system(size: 8))
                .foregroundStyle(accentGradient)
                .frame(width: 14)
        } else {
            Color.clear.frame(width: 14)
        }
    }

    private var contentArea: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(item.text)
                .lineLimit(2)
                .font(.system(size: 12, weight: isCopied ? .medium : .regular))
                .foregroundColor(isCopied ? .blue : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .blur(radius: isCopied ? 0.5 : 0)
        }
    }

    private var timeBadge: some View {
        Text(relativeTime(from: item.timestamp))
            .font(.system(size: 9, weight: .medium))
            .foregroundColor(.secondary)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Capsule().fill(Color.secondary.opacity(0.1)))
    }

    private var actions: some View {
        HStack(spacing: 1) {
            actionButton(
                icon: isCopied ? "checkmark.circle.fill" : "doc.on.doc",
                color: isCopied ? .green : .secondary,
                action: onCopy
            )
            actionButton(
                icon: item.isPinned ? "pin.slash" : "pin",
                color: item.isPinned ? .orange : .secondary,
                action: onPin
            )
            actionButton(
                icon: "xmark",
                color: .red.opacity(0.7),
                action: onDelete
            )
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.primary.opacity(0.06))
        )
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }

    private func actionButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(color)
                .frame(width: 22, height: 22)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var background: some View {
        if isCopied {
            Color.blue.opacity(0.08)
        } else if isHovered {
            Color.primary.opacity(0.05)
        }
    }

    @ViewBuilder
    private var overlayBorder: some View {
        if isCopied {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        }
    }

    private func relativeTime(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "now" }
        if interval < 3600 { return "\(Int(interval / 60))m" }
        if interval < 86400 { return "\(Int(interval / 3600))h" }
        return "\(Int(interval / 86400))d"
    }
}
