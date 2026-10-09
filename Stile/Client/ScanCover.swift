@preconcurrency import AVFoundation
import SwiftUI
import UIKit

/// Full-screen cover. Continue is the only step before the system camera prompt.
struct ScanCover: View {
    @EnvironmentObject private var store: LadderStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @StateObject private var camera = ScanSession()
    @State private var manual = ""
    @State private var note = "Point at the desk QR, or enter the code."
    @ScaledMetric(relativeTo: .body) private var bodySize: CGFloat = 17

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: StileSpace.steps(4)) {
                statusBody
                manualField
            }
            .padding(StileSpace.steps(4))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(DesignTokens.bg.ignoresSafeArea())
            .navigationTitle("Scan")
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
                        camera.stop()
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
        .onDisappear { camera.stop() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background || phase == .inactive {
                camera.stop()
            }
        }
        .onChange(of: camera.lastCode) { _, code in
            guard let code else { return }
            apply(code)
        }
    }

    @ViewBuilder
    private var statusBody: some View {
        switch camera.phase {
        case .needsPrompt:
            Text("Scan a desk QR to open that visit.")
                .font(StileFont.body(bodySize))
                .foregroundStyle(DesignTokens.ink)
            Spacer(minLength: 0)
            Button("Continue") {
                camera.requestAccess()
            }
            .buttonStyle(MarkButtonStyle(role: .primary, loading: false))
        case .denied:
            Text("Camera is off.")
                .font(StileFont.display(28))
                .foregroundStyle(DesignTokens.ink)
            Text("Scan needs the camera. Open Settings, then return to this cover.")
                .font(StileFont.body(bodySize))
                .foregroundStyle(DesignTokens.muted)
            Spacer(minLength: 0)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            .buttonStyle(MarkButtonStyle(role: .primary, loading: false))
        case .live:
            ScanPreview(session: camera.session)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: StileRadius.card, style: .continuous))
            Text(note)
                .font(StileFont.caption(13))
                .foregroundStyle(DesignTokens.muted)
        case .failed:
            Text("Scan failed. Try again.")
                .font(StileFont.body(bodySize))
                .foregroundStyle(DesignTokens.ink)
            Button("Try again") {
                camera.requestAccess()
            }
            .buttonStyle(MarkButtonStyle(role: .quiet, loading: false))
        }
    }

    private var manualField: some View {
        VStack(alignment: .leading, spacing: StileSpace.steps(2)) {
            #if targetEnvironment(simulator)
            Text("Simulator codes")
                .font(StileFont.caption(13))
                .foregroundStyle(DesignTokens.muted)
            ForEach(store.document.clients) { client in
                Button(client.name) {
                    apply(client.deskCode)
                }
                .buttonStyle(MarkButtonStyle(role: .quiet, loading: false))
            }
            #endif
            TextField("Desk code", text: $manual)
                .keyboardType(.numberPad)
                .font(StileFont.body(bodySize))
                .textFieldStyle(.roundedBorder)
                .onChange(of: manual) { _, value in
                    let digits = value.filter(\.isNumber)
                    if digits != value { manual = digits }
                }
            Button("Open visit") {
                apply(manual)
            }
            .buttonStyle(MarkButtonStyle(role: .primary, loading: false))
        }
    }

    private func apply(_ raw: String) {
        if store.openDeskCode(raw) {
            camera.stop()
            dismiss()
        } else {
            note = "Scan failed. Try again."
        }
    }
}

enum ScanPhase {
    case needsPrompt
    case denied
    case live
    case failed
}

@MainActor
final class ScanSession: ObservableObject {
    @Published var phase: ScanPhase
    @Published var lastCode: String?
    let session = AVCaptureSession()
    private let sink = ScanSink()
    private var configured = false

    init() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            phase = .live
        case .denied, .restricted:
            phase = .denied
        case .notDetermined:
            phase = .needsPrompt
        @unknown default:
            phase = .needsPrompt
        }
        if phase == .live {
            configure()
            start()
        }
    }

    func requestAccess() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            Task { @MainActor in
                if granted {
                    self.phase = .live
                    self.configure()
                    self.start()
                } else {
                    self.phase = .denied
                }
            }
        }
    }

    func stop() {
        let box = SessionBox(session)
        DispatchQueue.global(qos: .userInitiated).async {
            box.stop()
        }
    }

    private func start() {
        let box = SessionBox(session)
        DispatchQueue.global(qos: .userInitiated).async {
            box.start()
        }
    }

    private func configure() {
        guard configured == false else { return }
        session.beginConfiguration()
        session.sessionPreset = .high
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            phase = .failed
            return
        }
        session.addInput(input)
        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else {
            session.commitConfiguration()
            phase = .failed
            return
        }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(sink, queue: .main)
        output.metadataObjectTypes = [.qr]
        sink.onCode = { [weak self] value in
            self?.lastCode = value
        }
        session.commitConfiguration()
        configured = true
    }
}

private final class SessionBox: @unchecked Sendable {
    let session: AVCaptureSession
    init(_ session: AVCaptureSession) { self.session = session }
    func start() {
        if session.isRunning == false { session.startRunning() }
    }
    func stop() {
        if session.isRunning { session.stopRunning() }
    }
}

private final class ScanSink: NSObject, AVCaptureMetadataOutputObjectsDelegate, @unchecked Sendable {
    var onCode: (@MainActor (String) -> Void)?

    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = object.stringValue else { return }
        let callback = onCode
        Task { @MainActor in
            callback?(value)
        }
    }
}

struct ScanPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewHost {
        let host = PreviewHost()
        host.preview.session = session
        host.preview.videoGravity = .resizeAspectFill
        return host
    }

    func updateUIView(_ uiView: PreviewHost, context: Context) {
        uiView.preview.session = session
    }

    final class PreviewHost: UIView {
        let preview = AVCaptureVideoPreviewLayer()

        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.addSublayer(preview)
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            preview.frame = bounds
        }
    }
}
