import UIKit

let myBackgroundColor: UIColor = UIColor.lightGray
let leftMargin: CGFloat = 20

class ModulePresenterView: UIView {
  var insideView: UIView
  var contentView: UIView? {
    willSet {
      if (self.contentView != nil) {
        self.contentView!.removeFromSuperview()
      }
    }
    didSet {
      if (self.contentView != nil) {
        self.addSubview(self.contentView!)
        self.contentView!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          self.contentView!.topAnchor.constraint(equalTo: self.insideView.topAnchor, constant: 5),
          self.contentView!.leadingAnchor.constraint(equalTo: self.insideView.leadingAnchor, constant: 5),
          self.insideView.bottomAnchor.constraint(equalTo: self.contentView!.bottomAnchor, constant: 5),
          self.insideView.trailingAnchor.constraint(equalTo: self.contentView!.trailingAnchor, constant: 5),
        ])
      }
    }
  }
  @objc var vPosition: CGFloat = 0

  override init(frame: CGRect) {
    self.insideView = UIView(frame: CGRect.zero)
    self.insideView.translatesAutoresizingMaskIntoConstraints = false
    self.insideView.layer.backgroundColor = UIColor.lightGray.cgColor
    self.insideView.layer.cornerRadius = 5
    super.init(frame: frame)
    self.layer.backgroundColor = UIColor.clear.cgColor
    self.addSubview(self.insideView)
    NSLayoutConstraint.activate([
      self.insideView.topAnchor.constraint(equalTo: self.topAnchor),
      self.insideView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leftMargin),
      self.insideView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      self.insideView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
    ])
    self.isOpaque = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard let context = UIGraphicsGetCurrentContext() else { return }
    
    var point = CGPoint.init(x: 0, y: self.vPosition)
    point = self.convert(point, from: nil)
    context.beginPath()
    context.move(to: CGPoint(x: leftMargin, y: point.y - leftMargin / 2))
    context.addLine(to: CGPoint(x: 0, y: point.y))
    context.addLine(to: CGPoint(x: leftMargin, y: point.y + leftMargin / 2))
    context.closePath()
    
    context.setFillColor(myBackgroundColor.cgColor)
    context.fillPath()
  }
}
