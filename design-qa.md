# App Store Screenshot Design QA

- Source visual truth: `/Users/hsi/.codex/generated_images/019f7da1-42a5-7fe2-9dbd-6bb1da1ff0cb/exec-a19a4f11-df5d-490d-adca-d62d614c8957.png`
- Implementation screenshots: `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-01-wallpaper-palette.png`, `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-02-decorations.png`, `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-03-scanner-widget.png`
- Viewport: three adjacent 1284 × 2778 App Store screenshots; combined panorama 3852 × 2778
- State: Traditional Chinese showcase data, light appearance, cat / paint / minimal widget variants
- Full-view comparison evidence: `/tmp/colorinvo-app-store-design-qa.png`
- Focused comparison evidence: each 1284 × 2778 implementation screenshot was inspected at high resolution. Separate focused crops were unnecessary after the product captures were restored to their native aspect ratios; the remaining small UI labels, barcode edges, masks, and artwork details were legible in the individual full-resolution assets.

## Findings

- No actionable P0, P1, or P2 differences remain.
- Typography: system Traditional Chinese typography preserves the reference hierarchy, uses consistent weights, and remains readable in the isolated cards.
- Spacing and layout: the headline, connected barcode, and product proof keep a consistent vertical rhythm across all three crops. Each crop also reads independently.
- Colors: the navy-to-lavender-to-cyan-to-teal barcode transition stays restrained on an off-white surface and follows the selected visual direction.
- Image quality: the output is native 1284 × 2778 PNG. Real simulator captures and the supplied cat artwork are used; product UI is not stretched or approximated.
- Copy: the three requested messages are present, factual, and supported by visible product evidence.

## Comparison History

1. First pass found a P2 image-fidelity issue: the cat and paint captures were squeezed into narrow portrait cards. The compositor now normalizes Retina PNGs to their pixel dimensions and preserves the source aspect ratio.
2. Second pass found a P2 crop issue: the decoration cards included a clipped segmented control beneath their labels. The source crop now isolates the full-width widget artwork, and the two examples are stacked at their natural proportions.
3. Post-fix comparison found no remaining P0, P1, or P2 issues.

## Open Questions

- None.

## Implementation Checklist

- [x] Generate real simulator capture states.
- [x] Compose one connected panorama and crop it into three App Store assets.
- [x] Verify all output dimensions and isolated-card readability.
- [x] Compare the rendered panorama with the selected visual direction.

## Follow-up Polish

- The supporting copy can be localized to English later without changing the composition system.

final result: passed
