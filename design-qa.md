# App Store Screenshot Design QA

- Source visual direction: `/Users/hsi/.codex/generated_images/019f7da1-42a5-7fe2-9dbd-6bb1da1ff0cb/exec-a19a4f11-df5d-490d-adca-d62d614c8957.png`, superseded where the latest user brief explicitly requests a two-widget-only composition.
- Implementation screenshots: `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-01-wallpaper-palette.png`, `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-02-decorations.png`, `/Users/hsi/Projects/Apps/Mobile/ColorInvo/assets/screenshots/colorinvo-iphone-6-5-03-scanner-widget.png`
- Viewport: three adjacent 1284 × 2778 App Store screenshots; combined panorama 3852 × 2778
- State: Traditional Chinese showcase data, light appearance, cat and paint widget variants
- Full-view comparison evidence: `/tmp/colorinvo-app-store-design-qa.png`
- Focused comparison evidence: `/tmp/colorinvo-widget-cat-inner-490.png` and `/tmp/colorinvo-widget-wave-inner-490.png` verify that the compositor isolates the widgets from the in-app preview background.

## Findings

- No actionable P0, P1, or P2 differences remain.
- Typography: each card uses the same left-aligned 72 px headline and 36 px supporting line, starting at the same 96 px horizontal and top safe area.
- Spacing and layout: the panorama uses a shared 96 px outer inset. The cat widget crosses cards 1–2 from the upper-left; the paint widget crosses cards 2–3 and ends 96 px from the lower-right.
- Colors: the off-white canvas and native widget colors are unchanged across card boundaries.
- Image quality: only the two real widget captures remain. They preserve the native 329:155 widget ratio and rounded mask; no app preview background, standalone barcode, palette UI, cat asset, or scan badge is composited separately.
- Copy: each message describes the visible widget outcome—wallpaper-aware color, the two decoration choices, and scan-safe desktop access.

## Comparison History

1. The prior implementation had a P1 intent mismatch: five separate visual elements competed with the three messages. The composition was reduced to exactly two widgets.
2. The first two-widget pass had a P2 asset-fidelity issue: a strip of the in-app preview background remained inside the widget crop. The source crop was moved to the true widget bounds and clipped to the native rounded shape.
3. Post-fix comparison found no remaining P0, P1, or P2 issues.

## Open Questions

- None.

## Implementation Checklist

- [x] Apply one shared four-side padding system.
- [x] Use only the cat and paint widgets.
- [x] Span the widgets diagonally across cards 1–2 and 2–3.
- [x] Rewrite all copy around the visible widget intent.
- [x] Verify 1284 × 2778 output dimensions and isolated-card readability.

## Follow-up Polish

- English localization can reuse the same geometry with a smaller headline scale where needed.

final result: passed
