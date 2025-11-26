import Foundation

// MARK: - Network Delegate Implementation -

// In case SSL challenges should be handled
final class NetworkServicesDelegate: NSObject, URLSessionDelegate {

	let certificates: [SecCertificate]?

	init(certificates: [SecCertificate]? = nil) {
		self.certificates = certificates
	}

	public func urlSession(_ session: URLSession,
						   didReceive challenge: URLAuthenticationChallenge,
						   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		guard let certificates else {
			defaultHandler(challenge: challenge, completionHandler: completionHandler)
			return
		}
		self.customHandler(certificates: certificates,
						   challenge: challenge,
						   completionHandler: completionHandler)
	}
}

extension NetworkServicesDelegate {
	fileprivate func defaultHandler(challenge: URLAuthenticationChallenge,
									completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		guard let challenge = challenge.protectionSpace.serverTrust else {
			completionHandler(.performDefaultHandling, nil)
			return
		}
		completionHandler(.useCredential, URLCredential(trust: challenge))
	}

	fileprivate func customHandler(certificates: [SecCertificate],
								   challenge: URLAuthenticationChallenge,
								   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		let policies = NSMutableArray()
		policies.add(SecPolicyCreateBasicX509())

		// Challenge must have a certificate
		guard let serverTrust = challenge.protectionSpace.serverTrust,
			  SecTrustSetPolicies(serverTrust, policies) == noErr,
			  SecTrustSetAnchorCertificates(serverTrust, certificates as CFArray) == noErr,
			  SecTrustSetAnchorCertificatesOnly(serverTrust, false) == noErr else {
			completionHandler(.cancelAuthenticationChallenge, nil)
			return
		}

		var error: CFError?
		let certIsValid = SecTrustEvaluateWithError(serverTrust, &error)

		if certIsValid {
			completionHandler(.useCredential, URLCredential(trust: serverTrust))
		} else {
			if let error {
				let errorCode = CFErrorGetCode(error)
				if errorCode == Int(errSecCertificateExpired) ||
				   errorCode == Int(errSecHostNameMismatch) ||
				   errorCode == Int(errSecNotTrusted) {
					completionHandler(.performDefaultHandling, nil)
				} else {
					completionHandler(.cancelAuthenticationChallenge, nil)
				}
			} else {
				completionHandler(.cancelAuthenticationChallenge, nil)
			}
		}
	}
}
