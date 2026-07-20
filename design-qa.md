# App Store Screenshot Design QA

- Source visual truth: `/tmp/colorinvo-mustard-panorama.png`, revised by the latest user brief to set the orange widget bars to `#222222` and move the decoration copy group closer to the cat widget.
- Implementation screenshots: `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-01-wallpaper-palette.png`, `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-02-decorations.png`, `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-03-scanner-widget.png`
- Viewport: three adjacent 1284 × 2778 App Store screenshots; combined panorama 3852 × 2778.
- State: Traditional Chinese showcase data, light appearance, orange paint widget with `#222222` bars and blue cat widget.
- Full-view comparison evidence: `/tmp/colorinvo-black-bars-comparison.png`.
- Focused comparison evidence: `/tmp/colorinvo-black-bars-contact.png` verifies the three isolated-card crops, copy emphasis, and the tighter cat/copy grouping.

## Findings

- No actionable P0, P1, or P2 differences remain.
- Fonts and typography: headlines remain 88 px black and supporting text remains 44 px semibold. Color emphasis is limited to 桌布配色、不再破壞桌布氛圍、額外裝飾、安全可掃、商用反射率規範、好看 and 好掃. All other words use the established navy hierarchy, and all copy remains on one line without truncation.
- Spacing and layout rhythm: the orange paint widget begins 96 px from the panorama's top-left and the blue cat widget ends 96 px from the bottom-right. Both retain their native 329:155 ratio. Their frames are centered on the first and second panel seams respectively. The card 2 copy group moved 60 px downward, leaving 104 px below the orange widget and 50 px above the cat widget, so Gestalt proximity associates it with the cat. Card 1 copy remains at the bottom and card 3 copy remains at the top.
- Colors and visual tokens: the paint area remains app-icon orange `#FF9770`, its scanner-safe background remains peach `#FFE4D9`, and its barcode bars are now neutral black `#222222`. The blue widget retains its tint derived from app-icon blue `#70D6FF`. Under the app's red-light reflectance model, the blue pair has background/bar reflectance 0.749/0.000 and symbol contrast 0.749; the orange widget pair has 1.000/0.133 and symbol contrast 0.867. Both exceed the 0.70 commercial guidance threshold.
- Image quality and asset fidelity: both elements are real widget captures, not reconstructed illustrations. Their native masks, barcode geometry, cat damage treatment, paint shape, and shadows remain sharp at 1284 × 2778 output.
- Copy and content: card 2 now reads 選擇額外裝飾. The requested benefit phrases are highlighted exactly, and the three messages retain the bottom / middle / top sequence.

## Comparison History

1. The previous two-widget version used one blue palette, placed the cat upper-left and paint lower-right, and aligned all copy at the top.
2. The revised implementation swaps the widgets, introduces brand-derived scan-safe orange and blue states, centers each widget on its seam, and redistributes the copy to use the negative space.
3. The latest refinement replaced the orange paint state with dark yellow, changed 裝飾 to 額外裝飾, and removed emphasis from 小工具 and 貓貓 in favor of the requested benefit phrases.
4. The correction restored the orange paint and peach background, limited dark yellow to the barcode bars, and added blue emphasis to 不再破壞桌布氛圍.
5. The final color refinement changed those bars to `#222222` and moved the card 2 copy group 60 px closer to the cat widget.
6. The full panorama and isolated-card comparison found no remaining P0, P1, or P2 issues.

## Open Questions

- None.

## Implementation Checklist

- [x] Swap paint and cat widget positions.
- [x] Center both widget frames on their respective seams.
- [x] Preserve the native widget aspect ratio and shared 96 px outer inset.
- [x] Keep the orange paint and peach background while changing only its barcode bars to scan-safe `#222222`.
- [x] Place card copy at the bottom, between the widgets, and at the top.
- [x] Restrict brand-color emphasis to the seven requested benefit phrases.
- [x] Group the decoration copy more closely with the cat widget through vertical proximity.
- [x] Verify all three 1284 × 2778 outputs and standalone crops.

## Follow-up Polish

- None required for this pass.

final result: passed
