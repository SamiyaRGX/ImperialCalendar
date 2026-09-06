import SwiftUI

struct ContentView: View {
    enum Page: String, CaseIterable, Identifiable {
        case calendar, converter, events, about
        var id: String { rawValue }
        var title: String {
            switch self {
            case .calendar:  return "تقویم"
            case .converter: return "تبدیل تاریخ"
            case .events:    return "رویدادها"
            case .about:     return "درباره"
            }
        }
        var icon: String {
            switch self {
            case .calendar:  return "calendar"
            case .converter: return "arrow.left.arrow.right"
            case .events:    return "sparkles"
            case .about:     return "info.circle"
            }
        }
    }

    @State private var page: Page = .calendar
    @State private var showMenu = false

    var body: some View {
        ZStack {
            activeScreen
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))

            if showMenu {
                Color.black.opacity(0.35).ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) { showMenu = false }
                    }
                HStack {
                    Spacer(minLength: 0)
                    MenuPanel(page: $page, showMenu: $showMenu)
                        .frame(width: 300)
                        .transition(.move(edge: .trailing))
                }
                .ignoresSafeArea(edges: .vertical)
            }
        }
    }

    @ViewBuilder
    private var activeScreen: some View {
        switch page {
        case .calendar:  CalendarScreen(onMenu: openMenu)
        case .converter: ConverterScreen(onMenu: openMenu)
        case .events:    EventsScreen(onMenu: openMenu)
        case .about:     AboutScreen(onMenu: openMenu)
        }
    }

    private func openMenu() {
        withAnimation(.easeInOut(duration: 0.25)) { showMenu = true }
    }
}

struct MenuPanel: View {
    @Binding var page: ContentView.Page
    @Binding var showMenu: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Image("Logo")
                    .resizable()
                    .frame(width: 54, height: 54)
                    .cornerRadius(12)
                VStack(alignment: .leading, spacing: 2) {
                    Text("گاه شمار شاهنشاهی").font(.headline)
                    Text("گاه‌شمار ایران باستان و امروز")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 12)

            Divider().padding(.bottom, 6)

            ForEach(ContentView.Page.allCases) { p in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        page = p
                        showMenu = false
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: p.icon).frame(width: 26)
                        Text(p.title).font(.subheadline.weight(page == p ? .bold : .regular))
                        Spacer()
                        if page == p {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(12)
                    .background(page == p ? Color.accentColor.opacity(0.14) : Color.clear)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }

            Spacer()
            Text("نسخه ۲٫۰").font(.caption2).foregroundColor(.secondary)
        }
        .padding(18)
        .background(Color(.systemBackground))
    }
}

struct TopBar: View {
    let title: String
    let onMenu: () -> Void

    var body: some View {
        HStack {
            Button(action: onMenu) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            Spacer()
            Text(title).font(.headline)
            Spacer()
            Color.clear.frame(width: 28, height: 22)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
