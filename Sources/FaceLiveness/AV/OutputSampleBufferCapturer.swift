//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AVFoundation
import CoreImage

class OutputSampleBufferCapturer: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let faceDetector: FaceDetector
    let videoChunker: VideoChunker
    let onLog: ((_ message: String) -> Void)?

    init(faceDetector: FaceDetector, videoChunker: VideoChunker, onLog: ((_ message: String) -> Void)? = nil) {
        self.faceDetector = faceDetector
        self.videoChunker = videoChunker
        self.onLog = onLog
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        videoChunker.consume(sampleBuffer)

        guard let imageBuffer = sampleBuffer.imageBuffer
        else { return }

        faceDetector.detectFaces(from: imageBuffer, onLog: onLog)
    }
}
