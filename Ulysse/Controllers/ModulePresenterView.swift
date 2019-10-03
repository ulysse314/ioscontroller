import UIKit

let myBackgroundColor: UIColor = UIColor.lightGray
let margin: CGFloat = 20

class ModulePresenterView: UIView {
  @objc var isVertical: Bool = true
  var verticalConstraints: Array<NSLayoutConstraint> = Array()
  var horizontalConstraints: Array<NSLayoutConstraint> = Array()
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
  @objc var position: CGFloat = 0

  override init(frame: CGRect) {
    self.insideView = UIView(frame: CGRect.zero)
    self.insideView.translatesAutoresizingMaskIntoConstraints = false
    self.insideView.layer.backgroundColor = UIColor.lightGray.cgColor
    self.insideView.layer.cornerRadius = 5
    super.init(frame: frame)
    self.layer.backgroundColor = UIColor.clear.cgColor
    self.addSubview(self.insideView)
    NSLayoutConstraint.activate([
      self.insideView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      self.insideView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
    ])
    self.verticalConstraints = [
      self.insideView.topAnchor.constraint(equalTo: self.topAnchor),
      self.insideView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
    ]
    self.horizontalConstraints = [
      self.insideView.topAnchor.constraint(equalTo: self.topAnchor, constant: margin),
      self.insideView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
    ]
    self.isOpaque = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard let context = UIGraphicsGetCurrentContext() else { return }
    context.beginPath()

    if self.isVertical {
      var point = CGPoint.init(x: 0, y: self.position)
      point = self.convert(point, from: nil)
      context.move(to: CGPoint(x: margin, y: point.y - margin / 2))
      context.addLine(to: CGPoint(x: 0, y: point.y))
      context.addLine(to: CGPoint(x: margin, y: point.y + margin / 2))
    } else {
      var point = CGPoint.init(x: self.position, y: 0)
      point = self.convert(point, from: nil)
      context.move(to: CGPoint(x: point.x - margin / 2, y: margin))
      context.addLine(to: CGPoint(x: point.x, y: 0))
      context.addLine(to: CGPoint(x: point.x + margin / 2, y: margin))
    }

    context.closePath()
    context.setFillColor(myBackgroundColor.cgColor)
    context.fillPath()
  }
  
  override func updateConstraints() {
    if self.isVertical {
      NSLayoutConstraint.deactivate(self.horizontalConstraints)
      NSLayoutConstraint.activate(self.verticalConstraints)
    } else {
      NSLayoutConstraint.deactivate(self.verticalConstraints)
      NSLayoutConstraint.activate(self.horizontalConstraints)
    }
    super.updateConstraints()
  }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with:event)
    if (view == self) {
      return nil
    }
    return view
  }
}
