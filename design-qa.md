# App Store Screenshot Design QA

- Source visual truth: `/tmp/colorinvo-v2-panorama.png`, revised by the latest user brief to swap the two widgets, center each decoration on a panel seam, use logo-orange and logo-blue scan-safe palettes, and distribute copy bottom / middle / top.
- Implementation screenshots: `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-01-wallpaper-palette.png`, `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-02-decorations.png`, `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-03-scanner-widget.png`
- Viewport: three adjacent 1284 × 2778 App Store screenshots; combined panorama 3852 × 2778.
- State: Traditional Chinese showcase data, light appearance, orange paint widget and blue cat widget.
- Full-view comparison evidence: `/tmp/colorinvo-v2-v3-comparison.png`.
- Focused comparison evidence: `/tmp/colorinvo-v3-standalone-contact.png` verifies the three isolated-card crops and the center-card composition.

## Findings

- No actionable P0, P1, or P2 differences remain.
- Fonts and typography: headlines increased from 72 px bold to 88 px black; supporting text increased from 36 px medium to 44 px semibold. Selected phrases use darker accessible derivatives of the logo orange and blue, while the remaining text keeps the established navy hierarchy. All copy remains on one line without truncation.
- Spacing and layout rhythm: the orange paint widget begins 96 px from the panorama's top-left and the blue cat widget ends 96 px from the bottom-right. Both retain their native 329:155 ratio. Their frames are centered on the first and second panel seams respectively. Card 1 copy sits at the bottom, card 2 copy occupies the space between widgets, and card 3 copy sits at the top.
- Colors and visual tokens: the decoration uses the exact app-icon orange `#FF9770`; the blue widget uses a scanner-safe tint derived from the app-icon blue `#70D6FF`. Under the app's red-light reflectance model, the blue pair has background/bar reflectance 0.749/0.000 and symbol contrast 0.749; the orange pair has 1.000/0.024 and symbol contrast 0.976. Both exceed the 0.70 commercial guidance threshold.
- Image quality and asset fidelity: both elements are real widget captures, not reconstructed illustrations. Their native masks, barcode geometry, cat damage treatment, paint shape, and shadows remain sharp at 1284 × 2778 output.
- Copy and content: the three supplied messages appear verbatim and are positioned in the requested bottom / middle / top sequence.

## Comparison History

1. The previous two-widget version used one blue palette, placed the cat upper-left and paint lower-right, and aligned all copy at the top.
2. The revised implementation swaps the widgets, introduces brand-derived scan-safe orange and blue states, centers each widget on its seam, and redistributes the copy to use the negative space.
3. The full panorama and isolated-card comparison found no remaining P0, P1, or P2 issues.

## Open Questions

- None.

## Implementation Checklist

- [x] Swap paint and cat widget positions.
- [x] Center both widget frames on their respective seams.
- [x] Preserve the native widget aspect ratio and shared 96 px outer inset.
- [x] Use distinct orange and blue brand palettes without violating commercial reflectance guidance.
- [x] Place card copy at the bottom, between the widgets, and at the top.
- [x] Increase font size and weight and add selective brand-color emphasis.
- [x] Verify all three 1284 × 2778 outputs and standalone crops.

## Follow-up Polish

- None required for this pass.

final result: passed
