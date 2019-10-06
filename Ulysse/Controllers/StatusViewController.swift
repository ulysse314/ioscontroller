import UIKit

class StatusViewController: UIViewController {
  
  @objc var gamepadConnected: Bool = true
  var errorLabel: UILabel = UILabel()
  var timeLabel: UILabel = UILabel()
  var phoneBatteryLabel: UILabel = UILabel()
  var withoutErrorConstraints: Array<NSLayoutConstraint> = [NSLayoutConstraint]()
  var withErrorConstraints: Array<NSLayoutConstraint> = [NSLayoutConstraint]()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor(white: 1, alpha: 0.5)
    self.view.layer.cornerRadius = 10;
    self.view.layer.masksToBounds = true;
    self.view.layer.borderColor = UIColor.lightGray.cgColor
    self.view.layer.borderWidth = 1

    self.errorLabel.font = UIFont(name: "Menlo-Regular", size: 10)
    self.errorLabel.translatesAutoresizingMaskIntoConstraints = false
    self.errorLabel.textColor = UIColor.red
    self.view.addSubview(self.errorLabel)

    self.timeLabel.font = UIFont(name: "Menlo-Regular", size: 10)
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(self.timeLabel)

    self.phoneBatteryLabel.font = UIFont(name: "Menlo-Regular", size: 10)
    self.phoneBatteryLabel.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(self.phoneBatteryLabel)

    self.withoutErrorConstraints = [
      self.timeLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
    ]
    self.withErrorConstraints = [
      self.errorLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
      self.timeLabel.leadingAnchor.constraint(equalTo: self.errorLabel.trailingAnchor, constant: 6),
    ]
    self.phoneBatteryLabel.leadingAnchor.constraint(equalTo: self.timeLabel.trailingAnchor, constant: 6).isActive = true
    self.view.trailingAnchor.constraint(equalTo: self.phoneBatteryLabel.trailingAnchor, constant: 10).isActive = true
    
    self.errorLabel.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    self.errorLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    self.timeLabel.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    self.timeLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    self.phoneBatteryLabel.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    self.phoneBatteryLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    NSLayoutConstraint.activate(self.withoutErrorConstraints)
    self.updateView()
    self.triggerNextTimer()
  }

  @objc func update(values: Dictionary<String, Any>) {
  }
  
  func triggerNextTimer() {
    weak var weakSelf = self
    let now: Date = Date()
    let delta: Double = 1 + Double(Int(now.timeIntervalSinceReferenceDate)) - now.timeIntervalSinceReferenceDate
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delta * 1000))) {
      weakSelf?.updateView()
      weakSelf?.triggerNextTimer()
    }
  }
  
  func updateView() {
    var errors: Array<String> = [String]()
    if !gamepadConnected {
      errors.append("No gamepad")
    }
    if errors.count > 0 {
      self.errorLabel.text = errors.joined(separator: " ")
      self.errorLabel.isHidden = false
      NSLayoutConstraint.deactivate(self.withoutErrorConstraints)
      NSLayoutConstraint.activate(self.withErrorConstraints)
    } else {
      self.errorLabel.text = ""
      self.errorLabel.isHidden = true
      NSLayoutConstraint.deactivate(self.withErrorConstraints)
      NSLayoutConstraint.activate(self.withoutErrorConstraints)
    }

    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = "HH:mm:ss"
    let time: String = dateFormatterGet.string(from: Date())
    self.timeLabel.text = "\(time)"

    var batteryStatus = ""
    switch UIDevice.current.batteryState {
    case .unknown:
      batteryStatus = "Unkn."
    case .unplugged:
      batteryStatus = "Unpl."
    case .charging:
      batteryStatus = "Char."
    case .full:
      batteryStatus = "Full"
    @unknown default:
      batteryStatus = " -- "
    }
    let batteryLevel: Int = Int(UIDevice.current.batteryLevel * 100)
    self.phoneBatteryLabel.text = "\(batteryLevel)% \(batteryStatus)"
    if (batteryLevel < 50) {
      self.phoneBatteryLabel.textColor = UIColor.red
    } else {
      self.phoneBatteryLabel.textColor = UIColor.black
    }
  }

}
