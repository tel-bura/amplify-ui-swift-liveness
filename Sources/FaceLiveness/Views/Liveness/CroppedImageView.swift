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
    layer.contentsRect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
    layer.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
    layer.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
  }
}