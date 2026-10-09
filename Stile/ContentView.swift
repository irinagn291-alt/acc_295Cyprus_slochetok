import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: LadderStore
    @State private var booted = false
    @State private var cover: LadderCover?
    @State private var launchApplied = false

    var body: some View {
        Group {
            if booted == false {
                DesignTokens.bg
            } else if store.document.onboardingComplete {
                LadderView(cover: $cover)
            } else {
                OnboardingView()
            }
        }
        .sheet(item: sheetBinding) { item in
            switch item {
            case .clients:
                ClientSheet()
            case .progress:
                ProgressSheet()
            case .settings:
                SettingsSheet()
            case .scan:
                EmptyView()
            }
        }
        .fullScreenCover(isPresented: scanPresented) {
            ScanCover()
        }
        .task {
            guard booted == false else { return }
            await store.load()
            await store.installDemoIfNeeded()
            booted = true
            applyLaunchIfNeeded()
        }
        .onChange(of: store.document.onboardingComplete) { _, done in
            if done {
                applyLaunchIfNeeded()
            }
        }
    }

    private var sheetBinding: Binding<LadderCover?> {
        Binding(
            get: {
                switch cover {
                case .clients, .progress, .settings:
                    return cover
                default:
                    return nil
                }
            },
            set: { cover = $0 }
        )
    }

    private var scanPresented: Binding<Bool> {
        Binding(
            get: { cover == .scan },
            set: { isOn in
                if isOn == false, cover == .scan {
                    cover = nil
                }
            }
        )
    }

    private func applyLaunchIfNeeded() {
        guard launchApplied == false, store.document.onboardingComplete else { return }
        launchApplied = true
        switch ReviewLaunch.screen {
        case "log":
            cover = .progress
        case "goals":
            cover = .clients
        case "settings":
            cover = .settings
        case "scan":
            cover = .scan
        default:
            cover = nil
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LadderStore(directory: FileManager.default.temporaryDirectory))
}
