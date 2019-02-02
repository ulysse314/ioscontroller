import UIKit

class ModuleButton: UIControl {

  var imageView: UIImageView
  var callback: ((_ button: ModuleButton)->())?
//  override var isHighlighted: Bool {
//    didSet {
//      if (self.isHighlighted) {
//        self.imageView.layer.backgroundColor = UIColor.lightGray.cgColor
//      } else {
//        self.imageView.layer.backgroundColor = nil
//      }
//    }
//  }
  override var isSelected: Bool {
    didSet {
      if (self.isSelected) {
        self.imageView.layer.backgroundColor = UIColor.blue.cgColor
      } else {
        self.imageView.layer.backgroundColor = nil
      }
    }
  }

  init(image: UIImage, callback: ((_ button: ModuleButton)->())?) {
    self.imageView = UIImageView(frame: CGRect.zero)
    self.imageView.image = image
    self.callback = callback
    super.init(frame: CGRect.zero)
    self.imageView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(self.imageView)
//    self.imageView.layer.backgroundColor = UIColor.blue.cgColor
    NSLayoutConstraint.activate([
      self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1),
      self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
      self.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 1),
      self.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 1),
      self.imageView.widthAnchor.constraint(equalToConstant: 32),
      self.imageView.heightAnchor.constraint(equalToConstant: 32),
    ])
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.black.cgColor
  }
  
  required init?(frame: NSCoder) {
    fatalError("init(frame:) has not been implemented")
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    self.imageView.layer.backgroundColor = UIColor.lightGray.cgColor
    return super.beginTracking(touch, with: event)
  }
  
  override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    if (event == nil || !self.point(inside: touch.location(in: self), with: event)) {
      self.imageView.layer.backgroundColor = nil
    } else {
      self.imageView.layer.backgroundColor = UIColor.lightGray.cgColor
    }
    return super.continueTracking(touch, with: event)
  }
  
  override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    super.endTracking(touch, with: event)
    if (event != nil && touch != nil && self.point(inside: touch!.location(in: self), with: event)) {
      self.isSelected = !self.isSelected
      if (self.callback != nil) {
        self.callback!(self)
      }
    }
  }
  
}
