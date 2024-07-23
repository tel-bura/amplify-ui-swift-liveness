//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SwiftUI
@_spi(PredictionsFaceLiveness) import AWSPredictionsPlugin

fileprivate let initialFaceDistanceThreshold: CGFloat = 0.32

extension FaceLivenessDetectionViewModel: FaceDetectionResultHandler {
    func process(newResult: FaceDetectionResult, onLog: ((_ message: String) -> Void)?) {
        switch newResult {
        case .noFace:
            if case .pendingFacePreparedConfirmation = livenessState.state {
                DispatchQueue.main.async {
                    self.livenessState.faceNotPrepared(reason: .noFace)
                }
            }
        case .multipleFaces:
            if case .pendingFacePreparedConfirmation = livenessState.state {
                DispatchQueue.main.async {
                    self.livenessState.faceNotPrepared(reason: .multipleFaces)
                }
            }
        case .singleFace(let face):
            var normalizedFace = normalizeFace(face)
            normalizedFace.boundingBox = normalizedFace.boundingBoxFromLandmarks(ovalRect: ovalRect)

            switch livenessState.state {
            case .pendingFacePreparedConfirmation:
                if face.faceDistance <= initialFaceDistanceThreshold {
                        DispatchQueue.main.async {
                            self.livenessState.awaitingRecording()
                            self.initializeLivenessStream()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.livenessState.beginRecording()
                        }
                    return
                } else {
                    DispatchQueue.main.async {
                        self.livenessState.faceNotPrepared(reason: .faceTooClose)
                    }
                    return
                }
            case .recording(ovalDisplayed: false):
                print("recording oval false")
                onLog?("recording oval false")
                drawOval(onComplete: {
                    self.sendInitialFaceDetectedEvent(
                        initialFace: normalizedFace.boundingBox,
                        videoStartTime: Date().timestampMilliseconds
                    )
                })
            case .recording(ovalDisplayed: true):
                guard let sessionConfiguration = sessionConfiguration else { return }
                print("recording oval true")
                let instruction = faceInOvalMatching.faceMatchState(
                    for: normalizedFace.boundingBox,
                    in: ovalRect,
                    challengeConfig: sessionConfiguration.ovalMatchChallenge
                )

                onLog?("recording oval true, instruction \(instruction)")

                handleInstruction(
                    instruction,
                    colorSequences: sessionConfiguration.colorChallenge.colors
                )
            case .awaitingFaceInOvalMatch:
                guard let sessionConfiguration = sessionConfiguration else { return }
                print("recording awaitingFaceInOvalMatch")
                onLog?("recording awaitingFaceInOvalMatch")
                let instruction = faceInOvalMatching.faceMatchState(
                    for: normalizedFace.boundingBox,
                    in: ovalRect,
                    challengeConfig: sessionConfiguration.ovalMatchChallenge
                )
                handleInstruction(
                    instruction,
                    colorSequences: sessionConfiguration.colorChallenge.colors
                )
            default: break

            }
        }
    }

    func handleNoFaceFit(instruction: Instructor.Instruction, percentage: Double) {
        self.livenessState.awaitingFaceMatch(with: instruction, nearnessPercentage: percentage)
        if noFitStartTime == nil {
            noFitStartTime = Date()
        }
        if let elapsedTime = noFitStartTime?.timeIntervalSinceNow, abs(elapsedTime) >= noFitTimeoutInterval {
            handleSessionTimedOut()
        }
    }
    
    func handleNoFaceDetected() {
        if noFitStartTime == nil {
            noFitStartTime = Date()
        }
        if let elapsedTime = noFitStartTime?.timeIntervalSinceNow, abs(elapsedTime) >= noFitTimeoutInterval {
            handleSessionTimedOut()
        }
    }

    func handleInstruction(
        _ instruction: Instructor.Instruction,
        colorSequences: [FaceLivenessSession.DisplayColor],
        onLog: ((_ message: String) -> Void)?
    ) {
        DispatchQueue.main.async {
            switch instruction {
                case .match:
                    print("handleInstruction update to match")
                    onLog?("handleInstruction update to match")
                    self.livenessState.faceMatched()
                    self.faceMatchedTimestamp = Date().timestampMilliseconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        onLog?("handleInstruction displaying freshness")
                        self.livenessViewControllerDelegate?.displayFreshness(colorSequences: colorSequences)
                    }
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    self.noFitStartTime = nil

                case .tooClose(_, let percentage),
                        .tooFar(_, let percentage),
                        .tooFarLeft(_, let percentage),
                        .tooFarRight(_, let percentage):
                    print("handleInstruction too far")
                    onLog?("handleInstruction too far")
                    self.handleNoFaceFit(instruction: instruction, percentage: percentage)
                case .none:
                    print("handleInstruction none")
                    onLog?("handleInstruction none")
                    self.handleNoFaceDetected()
                }
        }
    }
    
    private func handleSessionTimedOut() {
        noFitStartTime = nil
        DispatchQueue.main.async {
            self.livenessState
                .unrecoverableStateEncountered(.timedOut)
            self.captureSession.stopRunning()
        }
    }
}
