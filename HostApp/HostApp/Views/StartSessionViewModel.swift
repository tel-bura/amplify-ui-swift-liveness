//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI
import Amplify

class StartSessionViewModel: ObservableObject {
    @Published var presentationState: StartSessionView.PresentationState = .loading
    var window: UIWindow?

    var isSignedIn: Bool {
        presentationState == .signedIn {}
    }

    func setup() {
        Task { @MainActor in
            presentationState = .signedIn(action: signOut)
//            do {
//                let session = try await Amplify.Auth.fetchAuthSession()
//                presentationState = session.isSignedIn
//                ? .signedIn(action: signOut)
//                : .signedOut(action: signIn)
//            } catch {
//                print("Error fetching auth session", error)
//            }

        }
    }

    func createSession(_ completion: @escaping (String) -> Void) {
        Task { @MainActor in
            presentationState = .loading

            do {
                let data = try await createFaceLivenessSession(apiUrl: "https://1152-184-22-176-188.ngrok-free.app/graphql", kioskToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YTA3ZDhlMy1iZmEyLTQxOTAtYWQxOC03MTk3MThlNmM4YWMiLCJpYXQiOjE3MDA0MTQxMDd9.qhMOhW0qYFwMhRC4ZFzrxM3ljsb-OC2C5zuONmwGUA0", userToken: nil)
                completion(data.data!.createFaceLivenessSession.sessionId)
            } catch {
                print("Error creating session", error)
            }
        }
    }

    func signIn() {
        Task { @MainActor in
            presentationState = .loading
            do {
                let signInResult = try await Amplify.Auth.signInWithWebUI(presentationAnchor: window)
                if signInResult.isSignedIn {
                    presentationState = .signedIn(action: signOut)
                }
            } catch {
                print("Error signing in with web UI", error)
            }

        }
    }

    func signOut() {
        Task { @MainActor in
            presentationState = .loading
            _ = await Amplify.Auth.signOut()
            presentationState = .signedOut(action: signIn)
        }
    }
}
