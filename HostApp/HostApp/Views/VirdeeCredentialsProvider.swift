//
//  VirdeeCredentialsProvider.swift
//  kiosk
//
//  Created by admin on 10/11/2566 BE.
//

import Foundation
import Amplify
import AWSPluginsCore

struct VirdeeCredentials: AWSTemporaryCredentials {
  var accessKeyId: String
  var secretAccessKey: String
  var sessionToken: String
  var expiration: Date
  
  init(accessKeyId: String, secretAccessKey: String, sessionToken: String, expiration: Date) {
    self.accessKeyId = accessKeyId
    self.secretAccessKey = secretAccessKey
    self.sessionToken = sessionToken
    self.expiration = expiration
  }
}

struct VirdeeCredentialsProvider: AWSCredentialsProvider {
  var apiUrl: String
  var userToken: String?
  var kioskToken: String
  var userId: String?
  
  init(apiUrl: String, kioskToken: String, userToken: String?, userId: String?) {
    self.apiUrl = apiUrl
    self.userToken = userToken
    self.kioskToken = kioskToken
    self.userId = userId
  }

  func fetchAWSCredentials() async throws -> AWSCredentials {
    // Fetch the credentials
    let response = try await getAwsCredential(apiUrl: self.apiUrl, kioskToken: self.kioskToken, userToken: self.userToken, userId: self.userId)
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    let expireDate = dateFormatter.date(from:response.data.getAwsFaceLivenessCredential.expiration)!
    return VirdeeCredentials.init(accessKeyId: response.data.getAwsFaceLivenessCredential.accessKeyId, secretAccessKey: response.data.getAwsFaceLivenessCredential.secretAccessKey, sessionToken: response.data.getAwsFaceLivenessCredential.sessionToken, expiration: expireDate)
  }
}
