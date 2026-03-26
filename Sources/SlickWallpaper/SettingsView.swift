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
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                headerSection
                intervalSection
                categoriesSection
                fontSection
                Divider()
                applyNowSection
            }
            .padding(28)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(minWidth: 420, minHeight: 480)
    }

    // MARK: Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                Image(systemName: "photo.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("Slick Wallpaper")
                    .font(.title2.bold())
            }
            Text("Automatically applies beautiful gradient wallpapers with quotes.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var intervalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Update Interval", icon: "clock.fill")
            Picker("", selection: $settings.interval) {
                ForEach(UpdateInterval.allCases, id: \.self) { interval in
                    Text(interval.rawValue).tag(interval)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Quote Categories", icon: "quote.bubble.fill")
            Text("Select the categories to draw quotes from")
                .font(.caption)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))], spacing: 8) {
                ForEach(availableCategories, id: \.self) { category in
                    categoryToggle(category)
                }
            }
        }
    }

    private func categoryToggle(_ category: String) -> some View {
        let isOn = settings.enabledCategories.contains(category)
        return Button(action: {
            if isOn {
                // Don't allow deselecting all categories
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

    private var fontSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Typography", icon: "textformat")

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

            // Preview
            fontPreview
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

    private var applyNowSection: some View {
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
    }

    // MARK: Helper

    private func sectionHeader(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}
