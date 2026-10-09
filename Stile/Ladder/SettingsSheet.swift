import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// Local export, confirmed reset, onboarding again, and the contact page.
struct SettingsView: View {
    @EnvironmentObject private var store: LadderStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmName = ""
    @State private var resetting = false
    @State private var exportNote = ""
    @ScaledMetric(relativeTo: .largeTitle) private var display: CGFloat = 28
    @ScaledMetric(relativeTo: .body) private var bodySize: CGFloat = 17

    var body: some View {
        NavigationStack {
            Form {
                if store.document.clients.isEmpty && store.document.sessionNotes.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: StileSpace.steps(2)) {
                            Image("stl_EmptyList")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: StileSpace.steps(36))
                                .clipped()
                                .accessibilityHidden(true)
                            Text("Nothing stored yet.")
                                .font(StileFont.display(display))
                                .foregroundStyle(DesignTokens.ink)
                            Text("A saved visit will show up here after the first review.")
                                .font(StileFont.body(bodySize))
                                .foregroundStyle(DesignTokens.muted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowBackground(DesignTokens.bg)
                    }
                }
                if store.statusLine.isEmpty == false {
                    Section {
                        Text(store.statusLine)
                            .font(StileFont.body(bodySize))
                            .foregroundStyle(DesignTokens.ink)
                        Button("Try again") {
                            Task { await store.flush() }
                        }
                        .buttonStyle(MarkButtonStyle(role: .quiet, loading: false))
                    }
                }
                Section("On this device") {
                    if let data = store.exportJSON() {
                        ShareLink(
                            item: LadderFile(data: data),
                            preview: SharePreview("Visit export")
                        ) {
                            Label("Export visit JSON", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity, minHeight: StileSpace.steps(11), alignment: .leading)
                                .contentShape(Rectangle())
                        }
                    } else {
                        Text("Export failed. The visit is still on screen.")
                            .font(StileFont.body(bodySize))
                    }
                    if exportNote.isEmpty == false {
                        Text(exportNote)
                            .font(StileFont.caption(13))
                    }
                    Button("Run onboarding again") {
                        store.reopenOnboarding()
                        dismiss()
                    }
                    .frame(minHeight: StileSpace.steps(11))
                }
                Section("Clear this device") {
                    Text("Typing Stile removes every name, visit, and note. This cannot be undone.")
                        .font(StileFont.body(bodySize))
                        .foregroundStyle(DesignTokens.ink)
                    TextField("Type Stile", text: $confirmName)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button("Reset all data") {
                        Task { await reset() }
                    }
                    .buttonStyle(MarkButtonStyle(role: .destructive, loading: resetting))
                    .disabled(confirmName != "Slochetok" || resetting)
                }
                Section {
                    if let url = URL(string: "https://stile-ladder.pro/contact-us") {
                        Link(destination: url) {
                            Label("Contact Stile", systemImage: "link")
                                .frame(maxWidth: .infinity, minHeight: StileSpace.steps(11), alignment: .leading)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(DesignTokens.bg.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(minWidth: StileSpace.steps(11), minHeight: StileSpace.steps(11))
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .sheetArrival()
    }

    private func reset() async {
        resetting = true
        defer { resetting = false }
        await store.resetAllData()
        confirmName = ""
    }
}

typealias SettingsSheet = SettingsView

private struct LadderFile: Transferable {
    var data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { file in
            file.data
        }
    }
}
