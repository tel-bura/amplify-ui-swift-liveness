//
//  FaceLivenessService.swift
//  HostApp
//
//  Created by Thanaboon Burapanakan on 1/8/2567 BE.
//

import Foundation

struct Payload: Codable {
  var variables: String = "{}"
  var query: String?
  var mutation: String?
}

struct VirdeeGraphQLResponseError: Codable, CustomStringConvertible {
  var message: String
  var code: String?
  var extensions: VirdeeGraphQLErrorExtensions?
  
  var description: String {
    return "message: \(message), code: \(String(describing: code)), extensions: {\(String(describing: extensions?.description))}"
  }
}

struct VirdeeGraphQLErrorExtensions: Codable, CustomStringConvertible {
  var code: String
  
  var description: String {
    return "code: \(String(describing: code))"
  }
}

struct CreateFaceLivenessSessionResponse: Codable, CustomStringConvertible {
  var data: CreateFaceLivenessSessionData?
  var errors: [VirdeeGraphQLResponseError]?
  
  var description: String {
    return "data: {\(String(describing: data?.description))}, errors: {\(String(describing: errors?.description))}"
  }
}

struct CreateFaceLivenessSessionData: Codable, CustomStringConvertible {
  var createFaceLivenessSession: CreateFaceLivenessSession
  
  var description: String {
    return "createFaceLivenessSession: {\(createFaceLivenessSession.description)}"
  }
}

struct CreateFaceLivenessSession: Codable, CustomStringConvertible {
  var sessionId: String
  
  var description: String {
    return "sessionId: \(sessionId)"
  }
}

struct GetFaceLivenessSessionResultsResponse: Codable, CustomStringConvertible {
  var data: GetFaceLivenessSessionResultsData?
  var errors: [VirdeeGraphQLResponseError]?
  
  var description: String {
    return "data: {\(String(describing: data?.description))}, errors: {\(String(describing: errors?.description))}"
  }
}

struct GetFaceLivenessSessionResultsData: Codable, CustomStringConvertible {
  var getFaceLivenessSessionResults: GetFaceLivenessSessionResults
  
  var description: String {
    return "getFaceLivenessSessionResults: {\(getFaceLivenessSessionResults.description)}"
  }
}

struct GetFaceLivenessSessionResults: Codable, CustomStringConvertible {
  var sessionId: String
  var status: String
  var confidence: Double
  var faceImage: String
  var performFaceMatch: Bool?
  var isFaceMatch: Bool?
  var isFaceDetected: Bool?
  
  var description: String {
    return "sessionId: \(sessionId), status: \(status), confidence: \(confidence), performFaceMatch: \(String(describing: performFaceMatch)), isFaceMatch: \(String(describing: isFaceMatch)), isFaceDetected: \(String(describing: isFaceDetected))"
  }
}

struct GetAwsCredentialResponse: Codable, CustomStringConvertible {
  var data: GetAwsCredentialData
  var errors: [VirdeeGraphQLResponseError]?
  
  var description: String {
    return "data: {\(String(describing: data.description))}, errors: {\(String(describing: errors?.description))}"
  }
}

struct GetAwsCredentialData: Codable, CustomStringConvertible {
  var getAwsFaceLivenessCredential: GetAwsCredential
  
  var description: String {
    return "getAwsFaceLivenessCredential: {\(getAwsFaceLivenessCredential.description)}"
  }
}

struct GetAwsCredential: Codable, CustomStringConvertible {
  var accessKeyId: String
  var secretAccessKey: String
  var sessionToken: String
  var expiration: String
  
  var description: String {
    return "accessKeyId: \(accessKeyId), secretAccessKey: \(secretAccessKey), sessionToken: \(sessionToken), expiration: \(expiration)"
  }
}

func getAwsCredential(apiUrl: String, kioskToken: String, userToken: String?, userId: String?) async throws -> GetAwsCredentialResponse {
  var mutation = Queries().getAwsFaceLivenessCredential(userId: userId)
  let apiClient = APIClient<GetAwsCredentialResponse>(operationString: mutation)
  var request = apiClient.getRequest(apiUrl: apiUrl, kioskToken: kioskToken, userToken: userToken)
  
  let response = try await apiClient.getResponse(request: request)
  
  return response
}

func createFaceLivenessSession(apiUrl: String, kioskToken: String, userToken: String?) async throws -> CreateFaceLivenessSessionResponse {
  var mutation = Queries().createFaceLivenessSession()
  let apiClient = APIClient<CreateFaceLivenessSessionResponse>(operationString: mutation)
  var request = apiClient.getRequest(apiUrl: apiUrl, kioskToken: kioskToken, userToken: userToken)
  
  let response = try await apiClient.getResponse(request: request)
  
  return response
}

func getFaceLivenessSessionResults(apiUrl: String, kioskToken: String, sessionId: String, accessGrantId: String, performFaceMatch: Bool, workFlowType: String, userToken: String?, userId: String?) async throws -> GetFaceLivenessSessionResultsResponse {
  var mutation = Queries().getFaceLivenessSessionResults(sessionId: sessionId, accessGrantId: accessGrantId, performFaceMatch: performFaceMatch, workFlowType: workFlowType, userId: userId)
  let apiClient = APIClient<GetFaceLivenessSessionResultsResponse>(operationString: mutation)
  var request = apiClient.getRequest(apiUrl: apiUrl, kioskToken: kioskToken, userToken: userToken)
  
  let response = try await apiClient.getResponse(request: request)
  
  return response
}
