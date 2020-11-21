import UIKit

class ButtonView: UIView {
  let buttonImageView: ButtonImageView
  let label: UILabel = UILabel()
  var verticalConstraints: Array<NSLayoutConstraint> = [NSLayoutConstraint]()
  var horizontalConstraints: Array<NSLayoutConstraint> = [NSLayoutConstraint]()
  var verticalLabel: Bool = false {
    didSet {
      self.updateView()
    }
  }

  init(image: UIImage?, callback: ((_ buttonImageView: ButtonImageView)->())?) {
    self.buttonImageView = ButtonImageView(image: image, callback: callback)
    super.init(frame: CGRect.zero)
    self.addSubview(self.buttonImageView)
    self.addSubview(self.label)
    self.buttonImageView.translatesAutoresizingMaskIntoConstraints = false
    self.label.translatesAutoresizingMaskIntoConstraints = false
    self.horizontalConstraints = [
      self.buttonImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.label.leadingAnchor.constraint(equalTo: self.buttonImageView.trailingAnchor, constant: 4),
      self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.label.widthAnchor.constraint(equalToConstant: 35),

      self.buttonImageView.topAnchor.constraint(equalTo: self.topAnchor),
      self.buttonImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      self.label.topAnchor.constraint(equalTo: self.topAnchor),
      self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
    ]
    self.verticalConstraints = [
      self.buttonImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.buttonImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor),

      self.label.topAnchor.constraint(equalTo: self.topAnchor),
      self.label.bottomAnchor.constraint(equalTo: self.buttonImageView.topAnchor, constant: -4),
      self.buttonImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
    ]
    self.label.numberOfLines = 0
    self.label.isUserInteractionEnabled = false
    self.label.font = UIFont(name: "Menlo-Regular", size: 10)
    self.label.text = "12.5V\n20C"
    self.updateView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func updateView() {
    if self.verticalLabel {
      NSLayoutConstraint.deactivate(self.horizontalConstraints)
      NSLayoutConstraint.activate(self.verticalConstraints)
      self.label.textAlignment = .right
    } else {
      NSLayoutConstraint.deactivate(self.verticalConstraints)
      NSLayoutConstraint.activate(self.horizontalConstraints)
      self.label.textAlignment = .left
    }
  }
  
  func updateValues(value1: String?, value2: String?) {
    var text: String! = ""
    if (value1 != nil) {
      text = value1
    }
    text = text + "\n"
    if (value2 != nil) {
      text = text + value2!
    }
    self.label.text = text
  }
  
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with:event)
    if (view == self) {
      return nil
    }
    return view
  }

}
