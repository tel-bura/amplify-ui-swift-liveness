//
//  APIClient.swift
//  kiosk
//
//  Created by admin on 27/11/2566 BE.
//

import Foundation

struct APIClient<T: Decodable>: Encodable {
  var operationString: String
  
  enum CodingKeys: String, CodingKey {
      case query
  }
  
  func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(operationString, forKey: .query)
  }
  
  func getRequest(apiUrl: String, kioskToken: String, userToken: String?) -> URLRequest {
    var request = URLRequest(url: URL(string: apiUrl)!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let version = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    request.addValue(version, forHTTPHeaderField: "x-virdee-kiosk-version")
    request.addValue("K_\(randomAlphanumericString(16))", forHTTPHeaderField: "X-Request-Id")

    var token: String? = nil
    if (userToken != nil) {
      token = "Bearer \(userToken!)"
    }
    
    request.addValue(kioskToken, forHTTPHeaderField: "x-virdee-kiosk-authorization")
    
    let postData = try! JSONEncoder().encode(self)
    request.httpBody = postData
    
    return request
  }
  
  func getResponse(request: URLRequest) async throws -> T {
    let response = try await URLSession.shared.data(for: request)
    
    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = .iso8601
    
    let jsonData = response.0
    
    let graphQLResponse = try jsonDecoder.decode(T.self, from: jsonData)
    
    return graphQLResponse
  }
}
