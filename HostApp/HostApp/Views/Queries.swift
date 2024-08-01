//
//  Queries.swift
//  kiosk
//
//  Created by admin on 27/11/2566 BE.
//

import Foundation

struct Queries {
  func getAwsFaceLivenessCredential(userId: String?) -> String {
    return """
      mutation {
        getAwsFaceLivenessCredential(
          userId: "19d66d9e-e4ca-42a7-98b3-a7dfd90bfd74"
        ){
          accessKeyId
          secretAccessKey
          sessionToken
          expiration
        }
      }
    """
  }
  
  func createFaceLivenessSession() -> String {
    return """
      mutation {
        createFaceLivenessSession {
          sessionId
        }
      }
    """
  }
  
  func getFaceLivenessSessionResults(sessionId: String, accessGrantId: String, performFaceMatch: Bool, workFlowType: String, userId: String?) -> String {
    return """
      mutation {
        getFaceLivenessSessionResults(
          sessionId: "\(sessionId)"
          accessGrantId: "29dda4c0-7c38-4a94-8cf3-79895090b57e"
          performFaceMatch: \(performFaceMatch)
          workFlowType: "\(workFlowType)"
          userId: "19d66d9e-e4ca-42a7-98b3-a7dfd90bfd74"
        ) {
          sessionId
          status
          confidence
          faceImage
          performFaceMatch
          isFaceMatch
          isFaceDetected
        }
      }
    """
  }
  
  func searchFacesByImage(faceImage: String) -> String {
    return """
      searchFacesByImage(faceImage: "\(faceImage)") {
        isMatch
      }
    """
  }
}
