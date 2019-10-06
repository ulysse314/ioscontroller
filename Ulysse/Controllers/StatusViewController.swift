import UIKit

class StatusViewController: UIViewController {
  
  var phoneBatteryLabel: UILabel = UILabel()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor(white: 1, alpha: 0.5)
    self.view.layer.cornerRadius = 10;
    self.view.layer.masksToBounds = true;
    self.view.layer.borderColor = UIColor.lightGray.cgColor
    self.view.layer.borderWidth = 1

    self.phoneBatteryLabel.font = UIFont(name: "Menlo-Regular", size: 10)
    self.phoneBatteryLabel.translatesAutoresizingMaskIntoConstraints = false
    self.phoneBatteryLabel.numberOfLines = 0
    self.view.addSubview(self.phoneBatteryLabel)
    self.view.leadingAnchor.constraint(equalTo: self.phoneBatteryLabel.leadingAnchor, constant: -10).isActive = true
    self.view.trailingAnchor.constraint(equalTo: self.phoneBatteryLabel.trailingAnchor, constant: 10).isActive = true
    self.phoneBatteryLabel.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    self.phoneBatteryLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
  }

  @objc func update(values: Dictionary<String, Any>) {
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
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = "HH:mm:ss"
    let time: String = dateFormatterGet.string(from: Date())
    self.phoneBatteryLabel.text = "\(time) \(batteryLevel)% \(batteryStatus)"
  }

}
