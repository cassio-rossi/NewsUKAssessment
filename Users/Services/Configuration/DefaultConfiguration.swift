import Foundation
import NetworkLibrary

struct DefaultConfiguration: AppConfiguration {
	let customHost: CustomHost

    init() {
        // Read configuration from Info.plist
        guard let config = Bundle.main.object(forInfoDictionaryKey: "DefaultConfiguration") as? [String: String],
              let baseURL = config["BaseURL"],
              let url = URL(string: baseURL),
              let host = url.host else {
            fatalError("DefaultConfiguration missing from Info.plist. Please ensure Configuration/Debug.xcconfig is set up correctly.")
        }

        self.customHost = CustomHost(host: host, path: url.path)
    }

	init(customHost: CustomHost) {
		self.customHost = customHost
	}
}
