import UIKit

let myBackgroundColor: UIColor = UIColor.lightGray
let horizontalMargin: CGFloat = 20
let verticalMargin: CGFloat = 10

class ModulePresenterView: UIView {
  @objc var verticalButtons: Bool = true
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
      self.insideView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
    ])
    self.verticalConstraints = [
      self.insideView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: horizontalMargin),
      self.insideView.topAnchor.constraint(equalTo: self.topAnchor),
      self.insideView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
    ]
    self.horizontalConstraints = [
      self.insideView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.insideView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -verticalMargin),
      self.insideView.topAnchor.constraint(equalTo: self.topAnchor, constant: verticalMargin),
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

    if self.verticalButtons {
      var point = CGPoint.init(x: 0, y: self.position)
      point = self.convert(point, from: nil)
      context.move(to: CGPoint(x: horizontalMargin, y: point.y - horizontalMargin / 2))
      context.addLine(to: CGPoint(x: 0, y: point.y))
      context.addLine(to: CGPoint(x: horizontalMargin, y: point.y + horizontalMargin / 2))
    } else {
      var point = CGPoint.init(x: self.position, y: 0)
      point = self.convert(point, from: nil)
      context.move(to: CGPoint(x: point.x - verticalMargin, y: self.bounds.size.height - verticalMargin))
      context.addLine(to: CGPoint(x: point.x, y: self.bounds.size.height))
      context.addLine(to: CGPoint(x: point.x + verticalMargin, y: self.bounds.size.height - verticalMargin))
    }

    context.closePath()
    context.setFillColor(myBackgroundColor.cgColor)
    context.fillPath()
  }
  
  override func updateConstraints() {
    if self.verticalButtons {
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
