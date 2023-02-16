import XCTest

extension XCTestCase {
    // This is static because extensions cannot define stored properties.
    static var app = XCUIApplication()

    // Verifies that a `Button` with a given label exists.
    func buttonExists(_ label: String) throws {
        XCTAssertTrue(Self.app.buttons[label].exists)
    }

    // Enters text in a `SecureField` with a given label.
    func enterSecureText(label: String, text: String) {
        Self.app.secureTextFields[label].tap()
        for char in text {
            Self.app.keys[String(char)].tap()
        }

        /* Tests fail with this approach.
         let field = Self.app.secureTextFields[label]
         field.tap()
         field.typeText(text)
         */
    }

    // Enters text in a `TextField` with a given label.
    func enterText(label: String, text: String) {
        Self.app.textFields[label].tap()
        for char in text {
            let key = Self.app.keys[String(char)]
            key.tap()
        }

        /* Tests fail with this approach.
         let field = Self.app.textFields[label]
         field.tap()
         field.typeText(text)
         */
    }

    /*
     func labelExists(_ text: String, wait: Double = 0) throws {
         let element = Self.app.label[text]
         let exists = element.waitForExistence(timeout: wait)
         XCTAssertTrue(exists)
     }
     */

    // Taps a `Button` with a given label.
    func tapButton(label: String) {
        Self.app.buttons[label].tap()
    }

    func tapTabBarButton(label: String) {
        let tabBar = Self.app.tabBars.element
        let button = tabBar.buttons[label]
        button.tap()
    }

    // Searches for text anywhere on the screen.
    func textExists(_ text: String) throws {
        XCTAssertTrue(Self.app.staticTexts[text].exists)
    }

    func textExists(_ text: String, wait: Double = 0) throws {
        let element = Self.app.staticTexts[text]
        let exists = element.waitForExistence(timeout: wait)
        XCTAssertTrue(exists)
    }

    // Searches for text in a view with a specific `accessibilityIdentifier`.
    func textExists(identifier: String, text: String) throws {
        let actual = Self.app.staticTexts[identifier].label
        XCTAssertEqual(text, actual)
    }
}
