class CroppedImageView: UIImageView {
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let radius = min(frame.width, frame.height) / 2
    let path = UIBezierPath(arcCenter: CGPoint(x: frame.width / 2, y: frame.height / 2),
                             radius: radius,
                             startAngle: 0,
                             endAngle: CGFloat(2 * Double.pi),
                             clockwise: true)
    
    let maskLayer = CAShapeLayer()
    maskLayer.path = path.cgPath
    layer.mask = maskLayer
  }
}