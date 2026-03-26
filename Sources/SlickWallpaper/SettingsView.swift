import SwiftUI
import AppKit

// MARK: - SettingsView

struct SettingsView: View {
    @ObservedObject private var settings = UserSettings.shared

    private let availableCategories = UserSettings.allCategories.sorted()
    private let availableFonts: [String] = [
        "Georgia", "Palatino", "Times New Roman",
        "Optima", "Gill Sans", "Futura",
        "Helvetica Neue", "Avenir", "Baskerville",
        "American Typewriter"
    ]

    var body: some View {
        TabView {
            aestheticsTab
                .tabItem { Label("Aesthetics", systemImage: "paintpalette.fill") }
            quotesTab
                .tabItem { Label("Quotes", systemImage: "quote.bubble.fill") }
            displaysTab
                .tabItem { Label("System", systemImage: "gearshape.fill") }
        }
        .padding(20)
        .frame(width: 540, height: 620)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Tab: Aesthetics

    private var aestheticsTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Typography
                VStack(alignment: .leading, spacing: 10) {
                    sectionHeader("Typography & Style", icon: "textformat")

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Font Family")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            Picker("", selection: $settings.fontFamily) {
                                ForEach(availableFonts, id: \.self) { font in
                                    Text(font).tag(font)
                                }
                            }
                            .frame(width: 200)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Font Size: \(Int(settings.fontSize)) pt")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            Slider(value: $settings.fontSize, in: 24...96, step: 2)
                                .frame(width: 170)
                        }
                    }
                    fontPreview
                }

                Divider()

                // Layout
                VStack(alignment: .leading, spacing: 14) {
                    sectionHeader("Layout", icon: "rectangle.3.group")
                    
                    Picker("Quote Alignment", selection: $settings.quotePlacement) {
                        ForEach(QuotePlacement.allCases) { placement in
                            Text(placement.rawValue).tag(placement)
                        }
                    }
                    .pickerStyle(.radioGroup)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Glass Backdrop Opacity: \(Int(settings.backdropOpacity * 100))%")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Slider(value: $settings.backdropOpacity, in: 0.0...1.0)
                            .frame(width: 250)
                    }
                }

                Divider()

                // Color Themes
                VStack(alignment: .leading, spacing: 10) {
                    sectionHeader("Color Themes", icon: "drop.fill")
                    Toggle("Sync with System Dark Mode", isOn: $settings.syncDarkMode)
                        .padding(.vertical, 4)
                }
            }
            .padding()
        }
    }

    private var fontPreview: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hue: 0.60, saturation: 0.8, brightness: 0.25),
                         Color(hue: 0.55, saturation: 0.6, brightness: 0.45)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(spacing: 8) {
                Text("\u{201C}Your quote will appear here\u{201D}")
                    .font(.custom(settings.fontFamily, size: max(14, settings.fontSize * 0.28)))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                Text("— Author")
                    .font(.custom(settings.fontFamily, size: max(11, settings.fontSize * 0.16)).italic())
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding()
        }
        .frame(height: 90)
    }

    // MARK: - Tab: Quotes

    @State private var newQuoteText: String = ""
    @State private var newQuoteAuthor: String = ""

    private var quotesTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Categories
                VStack(alignment: .leading, spacing: 10) {
                    sectionHeader("Quote Categories", icon: "books.vertical.fill")
                    Text("Select the thematic categories to randomly draw from.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))], spacing: 8) {
                        ForEach(availableCategories, id: \.self) { category in
                            categoryToggle(category)
                        }
                    }
                }

                Divider()

                // Custom Quotes
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("My Custom Quotes", icon: "pencil.and.outline")
                    Text("Add your own personal quotes to the rotation mix.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack {
                        TextField("Quote text...", text: $newQuoteText)
                            .textFieldStyle(.roundedBorder)
                        TextField("Author", text: $newQuoteAuthor)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                        Button("Add") {
                            guard !newQuoteText.isEmpty else { return }
                            let q = Quote(text: newQuoteText, author: newQuoteAuthor.isEmpty ? "Me" : newQuoteAuthor)
                            settings.customQuotes.append(q)
                            newQuoteText = ""
                            newQuoteAuthor = ""
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newQuoteText.isEmpty)
                    }

                    if !settings.customQuotes.isEmpty {
                        List {
                            ForEach(settings.customQuotes) { q in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\"\(q.text)\"").font(.callout)
                                        Text("— \(q.author)").font(.caption).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Button(role: .destructive) {
                                        settings.customQuotes.removeAll { $0.id == q.id }
                                    } label: {
                                        Image(systemName: "trash").foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .frame(height: 150)
                        .border(Color.secondary.opacity(0.2), width: 1)
                    }
                }
            }
            .padding()
        }
    }

    private func categoryToggle(_ category: String) -> some View {
        let isOn = settings.enabledCategories.contains(category)
        return Button(action: {
            if isOn {
                if settings.enabledCategories.count > 1 {
                    settings.enabledCategories.removeAll { $0 == category }
                }
            } else {
                settings.enabledCategories.append(category)
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn ? .blue : .secondary)
                Text(category.capitalized)
                    .font(.callout)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isOn ? Color.blue.opacity(0.12) : Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isOn ? Color.blue.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tab: System & Displays

    private var displaysTab: some View {
        VStack(alignment: .leading, spacing: 28) {
            
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("Automation", icon: "clock.fill")
                Picker("Update Interval", selection: $settings.interval) {
                    ForEach(UpdateInterval.allCases) { interval in
                        Text(interval.rawValue).tag(interval)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("Multi-Monitor Support", icon: "display.2")
                Text("Control how Wallpapers appear across multiple screens.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("", selection: $settings.multiMonitorMode) {
                    ForEach(MultiMonitorMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.radioGroup)
            }

            Spacer()
            Divider()

            HStack {
                Spacer()
                Button(action: {
                    DispatchQueue.main.async {
                        WallpaperPipeline.shared.generateAndApply()
                    }
                }) {
                    Label("Apply Wallpaper Now", systemImage: "photo.badge.arrow.down.fill")
                        .font(.body.bold())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 9)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                Spacer()
            }
            .padding(.bottom)
        }
        .padding()
    }

    // MARK: Helper

    private func sectionHeader(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}
