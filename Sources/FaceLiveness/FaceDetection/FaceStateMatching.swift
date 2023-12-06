//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import UIKit
@_spi(PredictionsFaceLiveness) import AWSPredictionsPlugin
import Amplify

struct FaceInOvalMatching {
    let instructor: Instructor
    private let storage = Storage()
    class Storage {
        var initialIOU: Double?
    }

    func faceMatchState(
        for face: CGRect,
        in ovalRect: CGRect?,
        challengeConfig: FaceLivenessSession.OvalMatchChallenge
    ) -> Instructor.Instruction {
        guard let oval = ovalRect else {
            return .none
        }

        print("oval minX \(oval.minX)")
        print("oval midX \(oval.midX)")
        print("oval maxX \(oval.maxX)")
        print("oval minY \(oval.minY)")
        print("oval midY \(oval.midY)")
        print("oval maxY \(oval.maxY)")
        print("oval width \(oval.width)")
        print("oval height \(oval.height)")

        print("face minX \(face.minX)")
        print("face midX \(face.midX)")
        print("face maxX \(face.maxX)")
        print("face minY \(face.minY)")
        print("face midY \(face.midY)")
        print("face maxY \(face.maxY)")
        print("face width \(face.width)")
        print("face height \(face.height)")

        let intersection = intersectionOverUnion(boxA: face, boxB: oval)
        print("intersection \(intersection)")
        let thresholds = Thresholds(oval: oval, challengeConfig: challengeConfig)
        print("thresholds intersection \(thresholds.intersection)")
        print("thresholds ovalMatchWidth \(thresholds.ovalMatchWidth)")
        print("thresholds ovalMatchHeight \(thresholds.ovalMatchHeight)")
        print("thresholds faceDetectionWidth \(thresholds.faceDetectionWidth)")
        print("thresholds faceDetectionHeight \(thresholds.faceDetectionHeight)")

        if storage.initialIOU == nil {
            storage.initialIOU = intersection
        }

        let initialIOU = storage.initialIOU!

        print("initialIOU \(initialIOU)")

        let faceMatchPercentage = calculateFaceMatchPercentage(
            intersection: intersection,
            initialIOU: initialIOU,
            thresholds: thresholds
        )
        print("faceMatchPercentage \(faceMatchPercentage)")

        let update: Instructor.Instruction

        if isMatch(face: face, oval: oval, intersection: intersection, thresholds: thresholds) {
            update = .match
        } else if isTooClose(face: face, oval: oval, intersection: intersection, thresholds: thresholds) {
            update = .tooClose(nearnessPercentage: faceMatchPercentage)
        } else {
            update = .tooFar(nearnessPercentage: faceMatchPercentage)
        }

        let instruction = instructor.instruction(for: update)
        return instruction
    }

    private func isTooClose(face: CGRect, oval: CGRect, intersection: Double, thresholds: Thresholds) -> Bool {
        oval.minY - face.minY > thresholds.faceDetectionHeight
        || face.maxY - oval.maxY > thresholds.faceDetectionHeight
        || (oval.minX - face.minX > thresholds.faceDetectionWidth && face.maxX - oval.maxX > thresholds.faceDetectionWidth)
    }

    private func isMatch(face: CGRect, oval: CGRect, intersection: Double, thresholds: Thresholds) -> Bool {
        intersection > thresholds.intersection
        && abs(oval.minX - face.minX) < thresholds.ovalMatchWidth
        && abs(oval.maxX - face.maxX) < thresholds.ovalMatchWidth
        && abs(oval.maxY - face.maxY) < thresholds.ovalMatchHeight
        
        print("isMatch \(intersection > thresholds.intersection
        && abs(oval.minX - face.minX) < thresholds.ovalMatchWidth
        && abs(oval.maxX - face.maxX) < thresholds.ovalMatchWidth
        && abs(oval.maxY - face.maxY) < thresholds.ovalMatchHeight)")
    }

    private func calculateFaceMatchPercentage(intersection: Double, initialIOU: Double, thresholds: Thresholds) -> Double {
        var faceMatchPercentage = (0.75 * (intersection - initialIOU)) / (thresholds.intersection - initialIOU) + 0.25
        faceMatchPercentage = max(min(1, faceMatchPercentage), 0)
        return faceMatchPercentage
    }

    private func intersectionOverUnion(boxA: CGRect, boxB: CGRect) -> Double {
        let xA = max(boxA.minX, boxB.minX)
        let yA = max(boxA.minY, boxB.minY)
        let xB = min(boxA.maxX, boxB.maxX)
        let yB = min(boxA.maxY, boxB.maxY)

        let intersectionArea = abs(max(0, xB - xA) * max(0, yB - yA))
        if intersectionArea == 0 { return 0 }

        let boxAArea = (boxA.maxY - boxA.minY) * (boxA.maxX - boxA.minX)
        let boxBArea = (boxB.maxY - boxB.minY) * (boxB.maxX - boxB.minX)

        return intersectionArea / (boxAArea + boxBArea - intersectionArea)
    }
}

extension FaceInOvalMatching {
    struct Thresholds {
        let intersection: Double
        let ovalMatchWidth: Double
        let ovalMatchHeight: Double
        let faceDetectionWidth: Double
        let faceDetectionHeight: Double

        init(oval: CGRect, challengeConfig: FaceLivenessSession.OvalMatchChallenge) {
            intersection = challengeConfig.oval.iouThreshold / 1.50
            ovalMatchWidth = oval.width * challengeConfig.oval.iouWidthThreshold
            ovalMatchHeight = oval.height * challengeConfig.oval.iouHeightThreshold
            faceDetectionWidth = oval.width * challengeConfig.face.iouWidthThreshold
            faceDetectionHeight = oval.height * challengeConfig.face.iouHeightThreshold
        }
    }
}
