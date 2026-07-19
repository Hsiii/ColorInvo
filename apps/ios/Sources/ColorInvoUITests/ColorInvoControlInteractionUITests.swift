import XCTest

final class ColorInvoControlInteractionUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    func testWallpaperControlsStayInteractiveAcrossPaletteAndWaveSequences() {
        launchShowcaseApp()
        selectDecoration("顏料")
        assertCoreControlsHittable()

        let operationSequences: [[ControlOperation]] = [
            [.palette(1), .palette(2), .palette(0), .wave(1), .wave(2), .wave(0)],
            [.wave(2), .palette(2), .wave(1), .palette(1), .wave(0), .palette(0)],
            [.palette(2), .palette(1), .palette(2), .wave(2), .wave(1), .wave(2)],
        ]

        for sequence in operationSequences {
            for operation in sequence {
                perform(operation)
                assertCoreControlsHittable()
            }
        }
    }

    func testColorPickersAcceptTapsAfterPaletteSwitching() {
        for identifier in ["backgroundColorPicker", "barColorPicker"] {
            launchShowcaseApp()

            perform(.palette(1))
            perform(.palette(2))
            perform(.palette(0))
            perform(.palette(2))

            let picker = control(identifier)
            XCTAssertTrue(picker.waitForExistence(timeout: 3), "\(identifier) should exist")
            scrollToHittable(picker)
            XCTAssertTrue(picker.isHittable, "\(identifier) should remain hittable")
            picker.tap()

            app.terminate()
        }
    }

    func testWaveColorControlsStayVisibleAndFollowWaveAvailability() {
        launchShowcaseApp()

        let waveColorButton = waveColorButton(at: 0)
        XCTAssertTrue(
            waveColorButton.waitForExistence(timeout: 3),
            "wave colors should remain visible for the cat decoration"
        )
        XCTAssertFalse(waveColorButton.isEnabled, "wave colors should be disabled for cat")

        selectDecoration("顏料")
        XCTAssertTrue(waveColorButton.isEnabled, "wave colors should enable for wallpaper paint")

        selectDecoration("貓貓")
        XCTAssertTrue(waveColorButton.exists, "wave colors should remain visible after leaving paint")
        XCTAssertFalse(waveColorButton.isEnabled, "wave colors should disable after leaving paint")
    }

    private func launchShowcaseApp() {
        app?.terminate()
        app = XCUIApplication()
        app.launchArguments = ["--showcase-data"]
        app.launchEnvironment["COLORINVO_SHOWCASE_DATA"] = "1"
        app.launch()

        XCTAssertTrue(
            app.buttons["wallpaperPaletteOption.0"].waitForExistence(timeout: 8),
            "Showcase wallpaper palette options should load"
        )
    }

    private func perform(_ operation: ControlOperation) {
        switch operation {
        case .palette:
            let button = app.buttons[operation.identifier]
            XCTAssertTrue(button.waitForExistence(timeout: 3), "\(operation.identifier) should exist")
            scrollToHittable(button)
            XCTAssertTrue(button.isHittable, "\(operation.identifier) should be hittable")
            button.tap()
            XCTAssertTrue(
                button.waitForValue("selected", timeout: 3),
                "\(operation.identifier) should become selected"
            )
        case .wave(let index):
            let button = waveColorButton(at: index)
            XCTAssertTrue(button.waitForExistence(timeout: 3), "\(operation.identifier) should exist")
            scrollToHittable(button)
            XCTAssertTrue(button.isHittable, "\(operation.identifier) should be hittable")
            XCTAssertTrue(button.hasUsableFrame, "\(operation.identifier) should have a usable tap frame")
            button.tap()
            XCTAssertTrue(
                selectedWaveColorIndicator().waitForValue("\(index)", timeout: 3),
                "\(operation.identifier) should become selected"
            )
        }
    }

    private func selectDecoration(_ label: String) {
        let picker = app.segmentedControls["decorationPicker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 3), "decoration picker should exist")

        let button = picker.buttons[label]
        XCTAssertTrue(button.waitForExistence(timeout: 3), "\(label) decoration should exist")
        scrollToHittable(button)
        XCTAssertTrue(button.isHittable, "\(label) decoration should be hittable")
        button.tap()
    }

    private func assertCoreControlsHittable(
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let identifiers = ["backgroundColorPicker", "barColorPicker"]

        for identifier in identifiers {
            let element = control(identifier)
            XCTAssertTrue(
                element.waitForExistence(timeout: 3),
                "\(identifier) should exist",
                file: file,
                line: line
            )
            XCTAssertTrue(element.hasUsableFrame, "\(identifier) should keep a usable frame", file: file, line: line)
        }

        for index in 0..<3 {
            let button = waveColorButton(at: index)
            XCTAssertTrue(
                button.waitForExistence(timeout: 3),
                "wave color button \(index) should exist",
                file: file,
                line: line
            )
            XCTAssertTrue(
                button.hasUsableFrame,
                "wave color button \(index) should keep a 40 point tap frame",
                file: file,
                line: line
            )
        }
    }

    private func control(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    private func waveColorButton(at index: Int) -> XCUIElement {
        app.buttons["波浪色彩 \(index + 1)"]
    }

    private func selectedWaveColorIndicator() -> XCUIElement {
        control("selectedWaveColorIndex")
    }

    private func scrollToHittable(_ element: XCUIElement) {
        for _ in 0..<4 where !element.isHittable {
            if element.frame.midY < app.frame.midY {
                app.swipeDown()
            } else {
                app.swipeUp()
            }
        }
    }
}

private enum ControlOperation {
    case palette(Int)
    case wave(Int)

    var identifier: String {
        switch self {
        case .palette(let index):
            return "wallpaperPaletteOption.\(index)"
        case .wave(let index):
            return "波浪色彩 \(index + 1)"
        }
    }
}

private extension XCUIElement {
    var hasUsableFrame: Bool {
        frame.width >= 40 && frame.height >= 40
    }

    func waitForValue(_ expectedValue: String, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate { element, _ in
            guard let element = element as? XCUIElement else {
                return false
            }

            return element.value as? String == expectedValue
        }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)

        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }
}
