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
//            presentationState = .loading
//            do {
//                let session = try await Amplify.Auth.fetchAuthSession()
//                presentationState = session.isSignedIn
//                ? .signedIn(action: signOut)
//                : .signedOut(action: signIn)
//            } catch {
//                presentationState = .signedOut(action: signIn)
//                print("Error fetching auth session", error)
//            }

        }
    }

    func createSession(_ completion: @escaping (String) -> Void) {
        Task { @MainActor in
            presentationState = .loading
//            let currentPresentationState = presentationState
//            presentationState = .loading
//            let request = RESTRequest(
//                apiName: "liveness",
//                path: "/liveness/create"
//            )

            do {
//                let data = try await Amplify.API.post(request: request)
//                let response = try JSONDecoder().decode(
//                    CreateSessionResponse.self,
//                    from: data
//                )
//                presentationState = currentPresentationState
//                completion(response.sessionId, nil)
                let data = try await createFaceLivenessSession(apiUrl: "https://backend-dev.virdee.co/graphql", kioskToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjYzI1MjkwYS00NWZjLTQ4NTgtYmJhNC0xMGEyYjMyZjY4OTciLCJpYXQiOjE3MjI0NDg0NDJ9.SfSQIK5_w6H0k6v17Idspm-qouV-KuZaW8mSaPSBPOo", userToken: nil)
                completion(data.data!.createFaceLivenessSession.sessionId)
            } catch {
//                presentationState = currentPresentationState
                print("Error creating session", error)
            }
        }
    }

    func signIn() {
//        Task { @MainActor in
//            presentationState = .loading
//            do {
//                let signInResult = try await Amplify.Auth.signInWithWebUI(presentationAnchor: window)
//                if signInResult.isSignedIn {
//                    presentationState = .signedIn(action: signOut)
//                }
//            } catch {
//                print("Error signing in with web UI", error)
//            }
//
//        }
    }

    func signOut() {
//        Task { @MainActor in
//            presentationState = .loading
//            _ = await Amplify.Auth.signOut()
//            presentationState = .signedOut(action: signIn)
//        }
    }
}
