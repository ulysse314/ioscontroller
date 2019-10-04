import UIKit

class ModuleButton: UIControl {

  var imageView: UIImageView = UIImageView(frame: CGRect.zero)
  var errorLabelContainer: UIView = UIImageView(frame: CGRect.zero)
  var errorLabel: UILabel = UILabel(frame: CGRect.zero)
  @objc var errorNumber: Int = 0 {
    didSet {
      self.errorLabelContainer.isHidden = self.errorNumber == 0
      self.errorLabel.isHidden = self.errorNumber == 0
      self.errorLabel.text = String(self.errorNumber)
    }
  }
  var callback: ((_ button: ModuleButton)->())?

  override var isSelected: Bool {
    didSet {
      if (self.isSelected) {
        self.imageView.layer.backgroundColor = UIColor.init(red: 0, green: 0.5, blue: 1, alpha: 1).cgColor
      } else {
        self.imageView.layer.backgroundColor = nil
      }
    }
  }

  init(image: UIImage?, callback: ((_ button: ModuleButton)->())?) {
    super.init(frame: CGRect.zero)
    self.imageView.translatesAutoresizingMaskIntoConstraints = false
    self.errorLabelContainer.isUserInteractionEnabled = false
    self.errorLabelContainer.translatesAutoresizingMaskIntoConstraints = false
    self.errorLabelContainer.backgroundColor = UIColor.red
    self.errorLabelContainer.isHidden = true
    self.errorLabelContainer.layer.cornerRadius = 7
    self.errorLabelContainer.layer.masksToBounds = true
    self.errorLabel.isUserInteractionEnabled = false
    self.errorLabel.translatesAutoresizingMaskIntoConstraints = false
    self.errorLabel.textColor = UIColor.white
    self.errorLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    self.errorLabel.layoutMargins = UIEdgeInsets.init(top: 0, left: 50, bottom: 0, right: 50)
    self.imageView.image = image
    self.imageView.layer.borderWidth = 1
    self.imageView.layer.borderColor = UIColor.black.cgColor
    self.imageView.contentMode = .center
    self.callback = callback
    self.layoutMargins = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
    self.addSubview(self.imageView)
    self.addSubview(self.errorLabelContainer)
    self.errorLabelContainer.addSubview(self.errorLabel)
    NSLayoutConstraint.activate([
      self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
      self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
      self.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 0),
      self.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 0),
      self.imageView.widthAnchor.constraint(equalToConstant: 34),
      self.imageView.heightAnchor.constraint(equalToConstant: 34),
      self.errorLabelContainer.centerXAnchor.constraint(equalTo: self.trailingAnchor),
      self.errorLabelContainer.centerYAnchor.constraint(equalTo: self.topAnchor),
      self.errorLabel.leadingAnchor.constraint(equalTo: self.errorLabelContainer.leadingAnchor, constant: 5),
      self.errorLabel.trailingAnchor.constraint(equalTo: self.errorLabelContainer.trailingAnchor, constant: -5),
      self.errorLabel.topAnchor.constraint(equalTo: self.errorLabelContainer.topAnchor, constant: 0),
      self.errorLabel.bottomAnchor.constraint(equalTo: self.errorLabelContainer.bottomAnchor, constant: 0),
    ])
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
