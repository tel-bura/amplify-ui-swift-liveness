import AVFoundation
import Foundation
import UIKit

class CroppedImageView: UIImageView {
  override func layoutSubviews() {
    super.layoutSubviews()
    
    guard let image = image else { return }
    
    let shorterSide = min(frame.width, frame.height)
    let scale = shorterSide / image.size.width
    
    contentMode = .scaleAspectFill
    layer.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
  }
}