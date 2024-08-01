//
//  StringUtils.swift
//  kiosk
//
//  Created by admin on 3/11/2566 BE.
//

import Foundation
import Foundation
func randomAlphanumericString(_ length: Int) -> String {
   let letters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
   let len = UInt32(letters.count)
   var random = SystemRandomNumberGenerator()
   var randomString = ""
   for _ in 0..<length {
      let randomIndex = Int(random.next(upperBound: len))
      let randomCharacter = letters[letters.index(letters.startIndex, offsetBy: randomIndex)]
      randomString.append(randomCharacter)
   }
   return randomString
}

extension String.StringInterpolation {
    mutating func appendInterpolation(if condition: @autoclosure () -> Bool, _ literal: StringLiteralType) {
        guard condition() else { return }
        appendLiteral(literal)
    }
}
