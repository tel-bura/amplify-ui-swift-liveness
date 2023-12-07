import AVFoundation
import Foundation
import UIKit

class CroppedImageView: UIImageView {
  override func layoutSubviews() {
    super.layoutSubviews()    
    contentMode = .scaleAspectFill
  }
}