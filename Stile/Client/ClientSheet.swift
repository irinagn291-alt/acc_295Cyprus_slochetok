import LocalAuthentication
import SwiftUI
import UIKit

/// Roster sheet. Face ID is the only biometric ask. Empty, filled, and error each fill the page.
struct ClientsView: View {
    @EnvironmentObject private var store: LadderStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var name = ""
    @State private var code = ""
    @State private var gateNote = ""
    @State private var addNote = ""
    @State private var unlocking = false
    @ScaledMetric(relativeTo: .largeTitle) private var display: CGFloat = 28
    @ScaledMetric(relativeTo: .body) private var bodySize: CGFloat = 17

    var body: some View {
        NavigationStack {
            Group {
                if store.statusLine.isEmpty == false && store.document.clients.isEmpty && store.document.rosterGatePassed {
                    errorPage
                } else if store.document.rosterGatePassed == false {
                    sealedPage
                } else if store.document.clients.isEmpty {
                    emptyRoster
                } else {
                    roster
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignTokens.bg.ignoresSafeArea())
            .navigationTitle("Clients")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
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

    private var sealedPage: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(4)) {
            Spacer(minLength: 0)
            Image("stl_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: StileSpace.steps(60))
                .clipped()
                .accessibilityHidden(true)
            Text("Clients are sealed.")
                .font(StileFont.display(display))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(gateNote.isEmpty ? "Unlock, then pick one." : gateNote)
                .font(StileFont.body(bodySize))
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            if showsSettings {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                .buttonStyle(MarkButtonStyle(role: .quiet, loading: false))
            }
            Button("Continue") {
                Task { await unlock() }
            }
            .buttonStyle(MarkButtonStyle(role: .primary, loading: unlocking))
            .disabled(unlocking)
        }
        .padding(StileSpace.steps(4))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var showsSettings: Bool {
        gateNote.isEmpty == false
    }

    private var emptyRoster: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(4)) {
            Image("stl_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: StileSpace.steps(40))
                .clipped()
                .accessibilityHidden(true)
            Text("No clients on this device.")
                .font(StileFont.display(display))
                .foregroundStyle(DesignTokens.ink)
            Text("Add a name and a desk code to open a visit.")
                .font(StileFont.body(bodySize))
                .foregroundStyle(DesignTokens.muted)
            addForm
            Spacer(minLength: 0)
        }
        .padding(StileSpace.steps(4))
    }

    private var errorPage: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(4)) {
            Text("The roster could not be read.")
                .font(StileFont.display(display))
                .foregroundStyle(DesignTokens.ink)
            Text(store.statusLine)
                .font(StileFont.body(bodySize))
                .foregroundStyle(DesignTokens.muted)
            Spacer(minLength: 0)
            Button("Try again") {
                Task { await store.load() }
            }
            .buttonStyle(MarkButtonStyle(role: .primary, loading: false))
        }
        .padding(StileSpace.steps(4))
        .frame(maxHeight: .infinity, alignment: .leading)
    }

    private var roster: some View {
        VStack(spacing: 0) {
            List {
                if store.statusLine.isEmpty == false {
                    Text(store.statusLine)
                        .font(StileFont.caption(13))
                        .foregroundStyle(DesignTokens.ink)
                        .listRowBackground(DesignTokens.surface)
                }
                ForEach(store.document.clients) { client in
                    Button {
                        store.showClient(client.id)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: StileSpace.steps(1)) {
                            Text(client.name)
                                .font(StileFont.headline(StileSpace.steps(5)))
                                .foregroundStyle(DesignTokens.ink)
                                .lineLimit(2)
                            Text(deskLabel(client.deskCode))
                                .font(StileFont.caption(13))
                                .foregroundStyle(DesignTokens.muted)
                        }
                        .frame(maxWidth: .infinity, minHeight: StileSpace.steps(11), alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(DesignTokens.surface)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            addForm
                .padding(StileSpace.steps(4))
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DesignTokens.bg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var addForm: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(2)) {
            TextField("Client name", text: $name)
                .font(StileFont.body(17))
                .textFieldStyle(.roundedBorder)
            TextField("Desk code", text: $code)
                .font(StileFont.body(17))
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .onChange(of: code) { _, value in
                    let digits = value.filter(\.isNumber)
                    if digits != value { code = digits }
                }
            if addNote.isEmpty == false {
                Text(addNote)
                    .font(StileFont.caption(13))
                    .foregroundStyle(DesignTokens.ink)
            }
            Button("Add to roster") {
                if store.addClient(name: name, deskCode: code) {
                    name = ""
                    code = ""
                    addNote = ""
                    dismiss()
                } else {
                    addNote = "Add failed. Use a name and an 8 to 14 digit desk code."
                }
            }
            .buttonStyle(MarkButtonStyle(role: .quiet, loading: false))
        }
    }

    private func deskLabel(_ code: String) -> String {
        "Desk \(code)"
    }

    private func unlock() async {
        unlocking = true
        defer { unlocking = false }
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            gateNote = "Face ID is unavailable. Open Settings to turn it on, then return here."
            return
        }
        do {
            let ok = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Stile uses Face ID to open the client roster on this device."
            )
            if ok {
                store.passRosterGate()
                gateNote = ""
            } else {
                gateNote = "Face ID did not confirm. Try again, or open Settings."
            }
        } catch {
            gateNote = "Face ID did not confirm. Try again, or open Settings."
        }
    }
}

typealias ClientSheet = ClientsView
