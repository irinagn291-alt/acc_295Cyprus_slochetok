import SpriteKit
import SwiftUI

/// One snap of flat geometric chips on the ladder hero after Set or Harvest.
struct ChipSnap: UIViewRepresentable {
    var token: Int
    var allowsMotion: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.allowsTransparency = true
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ view: SKView, context: Context) {
        guard allowsMotion, token != context.coordinator.token, token > 0 else { return }
        context.coordinator.token = token
        let scene = ChipScene(size: view.bounds.size == .zero ? CGSize(width: 200, height: 320) : view.bounds.size)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        view.presentScene(scene)
        scene.burst()
    }

    final class Coordinator {
        var token = 0
    }
}

private final class ChipScene: SKScene {
    func burst() {
        let shapes: [SKShapeNode] = [
            SKShapeNode(circleOfRadius: 10),
            SKShapeNode(rectOf: CGSize(width: 16, height: 16)),
            SKShapeNode(path: triangle())
        ]
        let origin = CGPoint(x: size.width * 0.5, y: size.height * 0.55)
        for (index, node) in shapes.enumerated() {
            node.fillColor = UIColor(DesignTokens.accent)
            node.strokeColor = UIColor(DesignTokens.ink)
            node.lineWidth = 1
            node.position = origin
            addChild(node)
            let dx = CGFloat(index - 1) * 36
            node.run(.sequence([
                .group([
                    .moveBy(x: dx, y: 48, duration: 0.18),
                    .fadeOut(withDuration: 0.36)
                ]),
                .removeFromParent()
            ]))
        }
    }

    private func triangle() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 12))
        path.addLine(to: CGPoint(x: 12, y: -8))
        path.addLine(to: CGPoint(x: -12, y: -8))
        path.closeSubpath()
        return path
    }
}
