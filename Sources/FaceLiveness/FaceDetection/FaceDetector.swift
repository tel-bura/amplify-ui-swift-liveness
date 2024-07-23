//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AVFoundation

protocol FaceDetector {
    func detectFaces(from buffer: CVPixelBuffer, onLog: ((_ message: String) -> Void)?)
    func setResultHandler(detectionResultHandler: FaceDetectionResultHandler)
}

protocol FaceDetectionResultHandler: AnyObject {
    func process(newResult: FaceDetectionResult, onLog: ((_ message: String) -> Void)?)
}

enum FaceDetectionResult {
    case noFace
    case singleFace(DetectedFace)
    case multipleFaces
}
