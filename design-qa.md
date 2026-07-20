# App Store Screenshot Design QA

- Source visual truth: `/tmp/colorinvo-smaller-copy-panorama.png`, revised by the latest user brief so both remaining copy groups occupy approximately 85% of their usable card width.
- Implementation screenshots: `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-01-wallpaper-palette.png`, `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-02-decorations.png`, `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-03-scanner-widget.png`
- Viewport: three adjacent 1284 × 2778 App Store screenshots; combined panorama 3852 × 2778.
- State: Traditional Chinese showcase data, light appearance, orange paint widget with `#222222` bars and blue cat widget.
- Full-view comparison evidence: `/tmp/colorinvo-85-copy-comparison.png`.
- Focused comparison evidence: `/tmp/colorinvo-85-copy-contact.png` verifies the three isolated-card crops, enlarged typography, opposing alignment, and the text-free center bridge.

## Findings

- No actionable P0, P1, or P2 differences remain.
- Fonts and typography: each line is fitted independently to 85% of the 1112 px usable card width. Both headlines render at 163 px black; the top-right supporting line renders at 75 px bold and the bottom-left supporting line at 65 px bold. Color emphasis remains limited to 桌布配色、不再破壞桌布氛圍、額外裝飾 and 安全可掃. All copy remains on one line without truncation.
- Spacing and layout rhythm: the orange paint widget begins 96 px from the panorama's top-left and the blue cat widget ends 96 px from the bottom-right. Both retain their native 329:155 ratio and stay centered on their seams. 提取桌布配色 is right-aligned in the panorama's top-right corner; 選擇額外裝飾 is left-aligned in the bottom-left corner. The opposite anchors balance the strip while the center card becomes an uninterrupted visual bridge.
- Colors and visual tokens: the paint area remains app-icon orange `#FF9770`, its scanner-safe background remains peach `#FFE4D9`, and its barcode bars are now neutral black `#222222`. The blue widget retains its tint derived from app-icon blue `#70D6FF`. Under the app's red-light reflectance model, the blue pair has background/bar reflectance 0.749/0.000 and symbol contrast 0.749; the orange widget pair has 1.000/0.133 and symbol contrast 0.867. Both exceed the 0.70 commercial guidance threshold.
- Image quality and asset fidelity: both elements are real widget captures, not reconstructed illustrations. Their native masks, barcode geometry, cat damage treatment, paint shape, and shadows remain sharp at 1284 × 2778 output.
- Copy and content: the 好看，也好掃 group is removed. Only 提取桌布配色 and 選擇額外裝飾 remain, with their existing supporting lines and requested color emphasis.

## Comparison History

1. The previous two-widget version used one blue palette, placed the cat upper-left and paint lower-right, and aligned all copy at the top.
2. The revised implementation swaps the widgets, introduces brand-derived scan-safe orange and blue states, centers each widget on its seam, and redistributes the copy to use the negative space.
3. The latest refinement replaced the orange paint state with dark yellow, changed 裝飾 to 額外裝飾, and removed emphasis from 小工具 and 貓貓 in favor of the requested benefit phrases.
4. The correction restored the orange paint and peach background, limited dark yellow to the barcode bars, and added blue emphasis to 不再破壞桌布氛圍.
5. The final color refinement changed those bars to `#222222` and moved the card 2 copy group 60 px closer to the cat widget.
6. The two-message refinement removed 好看，也好掃, enlarged the remaining copy, and anchored the two groups at opposite outer corners.
7. The typography refinement fits every remaining title and supporting line to approximately 85% of its usable card width.
8. The full panorama and isolated-card comparison found no remaining P0, P1, or P2 issues.

## Open Questions

- None.

## Implementation Checklist

- [x] Swap paint and cat widget positions.
- [x] Center both widget frames on their respective seams.
- [x] Preserve the native widget aspect ratio and shared 96 px outer inset.
- [x] Keep the orange paint and peach background while changing only its barcode bars to scan-safe `#222222`.
- [x] Remove the third copy group.
- [x] Enlarge the two remaining copy groups.
- [x] Fit every copy line to approximately 85% of the usable card width.
- [x] Right-align 提取桌布配色 at the top-right and left-align 選擇額外裝飾 at the bottom-left.
- [x] Verify all three 1284 × 2778 outputs and standalone crops.

## Follow-up Polish

- None required for this pass.

final result: passed
