@testable import AnalyticsLibrary
import Testing

@Suite("Analytics Tests")
struct AnalyticsTests {

    @Test("Analytics can be disabled")
    func analyticsCanBeDisabled() {
        let analytics = Analytics(isEnabled: false)
        #expect(!analytics.isEnabled)

        // Should not crash when disabled
        analytics.track(.screenView(name: "Test"))
    }

    @Test("Analytics is enabled by default")
    func analyticsIsEnabledByDefault() {
        let analytics = Analytics()
        #expect(analytics.isEnabled)
    }

    @Test("ScreenView event has correct name and parameters")
    func screenViewEventHasCorrectParameters() {
        let event = AnalyticsEvent.screenView(name: "Accounts")
        #expect(event.name == "screen_view")
        #expect(event.parameters["screen_name"] as? String == "Accounts")
    }

    @Test("ButtonTap event has correct parameters")
    func buttonTapEventHasCorrectParameters() {
        let event = AnalyticsEvent.buttonTap(name: "add_to_goal", screen: "Accounts")
        #expect(event.name == "button_tap")
        #expect(event.parameters["button_name"] as? String == "add_to_goal")
        #expect(event.parameters["screen"] as? String == "Accounts")
    }

    @Test("RoundUpSaved event has correct parameters")
    func roundUpSavedEventHasCorrectParameters() {
        let event = AnalyticsEvent.roundUpSaved(amount: 125, goalName: "Holiday")
        #expect(event.name == "round_up_saved")
        #expect(event.parameters["amount"] as? Int == 125)
        #expect(event.parameters["goal_name"] as? String == "Holiday")
    }

    @Test("Navigation event has correct parameters")
    func navigationEventHasCorrectParameters() {
        let event = AnalyticsEvent.navigation(from: "Accounts", to: "Goals")
        #expect(event.name == "navigation")
        #expect(event.parameters["from_screen"] as? String == "Accounts")
        #expect(event.parameters["to_screen"] as? String == "Goals")
    }

    @Test("Error event has correct parameters")
    func errorEventHasCorrectParameters() {
        let event = AnalyticsEvent.error(type: "network", message: "Connection failed")
        #expect(event.name == "error")
        #expect(event.parameters["error_type"] as? String == "network")
        #expect(event.parameters["error_message"] as? String == "Connection failed")
    }
}
