#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Vertical rung field and scale bead. Confined to the Ladder hero.
[[ stitchable ]] half4 rungField(float2 position, half4 currentColor, float beadY, float span) {
    float height = max(span, 1.0);
    float step = height / 11.0;
    float along = fmod(position.y, step);
    half rail = along < 3.0 ? half(0.35) : half(0.0);
    float dist = abs(position.y - beadY);
    half bead = dist < 16.0 ? half(1.0) : half(0.0);
    half3 ink = half3(0.235h, 0.235h, 0.235h);
    half3 accent = half3(0.745h, 0.349h, 1.0h);
    half3 paper = half3(currentColor.r, currentColor.g, currentColor.b);
    half3 color = mix(paper, ink, rail);
    color = mix(color, accent, bead * (1.0h - smoothstep(8.0, 16.0, dist)));
    return half4(color, 1.0h);
}
