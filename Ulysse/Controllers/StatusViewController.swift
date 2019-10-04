import UIKit

func networkName(networkType: Int) -> String {
  switch (networkType) {
  case 0:
    return "No Service";
    case 1:
      // 2G
    return "GSM";
    case 2:
      // 2G
    return "GPRS";
    case 3:
      // 2G
    return "EDGE";
    case 4:
      // 3G
    return "WCDMA";
    case 5:
      // 3G
    return "HSDPA";
    case 6:
      // 3G
    return "HSUPA";
    case 7:
      // 3G
    return "HSPA";
    case 8:
      // 3G
    return "TD-SCDMA";
    case 9:
      // 4G
    return "HSPA+)";
    case 10:
    return "EV-DO rev. 0";
    case 11:
    return "EV-DO rev. A";
    case 12:
    return "EV-DO rev. B";
    case 13:
    return "1xRTT";
    case 14:
    return "UMB";
    case 15:
    return "1xEVDV";
    case 16:
    return "3xRTT";
    case 17:
    return "HSPA+ 64QAM";
    case 18:
    return "HSPA+ MIMO";
    case 19:
      // 4G
    return "LTE";
    case 41:
      // 3G
    return "UMTS";
    case 44:
      // 3G
    return "HSPA";
    case 45:
      // 3G
    return "HSPA+";
    case 46:
      // 3G
    return "DC-HSPA+";
    case 64:
      // 3G
    return "HSPA";
  case 65:
      // 3G
    return "HSPA+";
  case 101:
      // 4G
    return "LTE";
  default:
    return "n/a";
  }
}

class StatusViewController: UIViewController {
  
  var batteryLabel: UILabel = UILabel()
  var gpsLabel: UILabel = UILabel()
  var cellularLabel: UILabel = UILabel()
  var piLabel: UILabel = UILabel()
  var motorTempLabel: UILabel = UILabel()
  var generalLabel: UILabel = UILabel()
  var phoneBatteryLabel: UILabel = UILabel()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor(white: 1, alpha: 0.5)
    self.view.layer.borderColor = UIColor.black.cgColor
    self.view.layer.borderWidth = 1
    
    self.batteryLabel.font = UIFont(name: "Menlo-Regular", size: 10)
    self.batteryLabel.translatesAutoresizingMaskIntoConstraints = false
    self.batteryLabel.numberOfLines = 0
    self.view.addSubview(self.batteryLabel)
    self.batteryLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
    self.batteryLabel.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    self.batteryLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    
    self.cellularLabel.font = UIFont(name: "Menlo-Regular", size: 10)
    self.cellularLabel.translatesAutoresizingMaskIntoConstraints = false
    self.cellularLabel.numberOfLines = 0
    self.view.addSubview(self.cellularLabel)
    self.cellularLabel.leadingAnchor.constraint(equalTo: self.batteryLabel.trailingAnchor, constant: 10).isActive = true
    self.cellularLabel.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    self.cellularLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

    self.gpsLabel.font = UIFont(name: "Menlo-Regular", size: 10)
    self.gpsLabel.translatesAutoresizingMaskIntoConstraints = false
    self.gpsLabel.numberOfLines = 0
    self.view.addSubview(self.gpsLabel)
    self.gpsLabel.leadingAnchor.constraint(equalTo: self.cellularLabel.trailingAnchor, constant: 10).isActive = true
    self.gpsLabel.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    self.gpsLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    
    self.piLabel.font = UIFont(name: "Menlo-Regular", size: 10)
    self.piLabel.translatesAutoresizingMaskIntoConstraints = false
    self.piLabel.numberOfLines = 0
    self.view.addSubview(self.piLabel)
    self.piLabel.leadingAnchor.constraint(equalTo: self.gpsLabel.trailingAnchor, constant: 10).isActive = true
    self.piLabel.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    self.piLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    
    self.motorTempLabel.font = UIFont(name: "Menlo-Regular", size: 10)
    self.motorTempLabel.translatesAutoresizingMaskIntoConstraints = false
    self.motorTempLabel.numberOfLines = 0
    self.view.addSubview(self.motorTempLabel)
    self.motorTempLabel.leadingAnchor.constraint(equalTo: self.piLabel.trailingAnchor, constant: 10).isActive = true
    self.motorTempLabel.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    self.motorTempLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    
    self.generalLabel.font = UIFont(name: "Menlo-Regular", size: 10)
    self.generalLabel.translatesAutoresizingMaskIntoConstraints = false
    self.generalLabel.numberOfLines = 0
    self.view.addSubview(self.generalLabel)
    self.generalLabel.leadingAnchor.constraint(equalTo: self.motorTempLabel.trailingAnchor, constant: 10).isActive = true
    self.generalLabel.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    self.generalLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    
    self.phoneBatteryLabel.font = UIFont(name: "Menlo-Regular", size: 10)
    self.phoneBatteryLabel.translatesAutoresizingMaskIntoConstraints = false
    self.phoneBatteryLabel.numberOfLines = 0
    self.view.addSubview(self.phoneBatteryLabel)
    self.view.trailingAnchor.constraint(equalTo: self.phoneBatteryLabel.trailingAnchor, constant: 10).isActive = true
    self.phoneBatteryLabel.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    self.phoneBatteryLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
  }

  @objc func update(values: Dictionary<String, Any>) {
    let batteryValues: Dictionary<String, Any>? = values["battery"] as? Dictionary
    let volt: String = String(format: "%.1f", getDouble(value: batteryValues?["volt"]))
    let ampere: String = String(format: "%.1f", getDouble(value: batteryValues?["amp"]))
    self.batteryLabel.text = " \(volt)V \n \(ampere)A "
    
    let gpsValues: Dictionary<String, Any>? = values["gps"] as? Dictionary
    let satCount: Int = gpsValues?["sat"] as? Int ?? 0
    let trackCount: Int = gpsValues?["tracked"] as? Int ?? 0
    self.gpsLabel.text = "\(trackCount)\n\(satCount)"

    let cellularValues: Dictionary<String, Any>? = values["cellular"] as? Dictionary
    let signalStrength: Int = cellularValues?["SignalIcon"] as? Int ?? 0
    let network: String = networkName(networkType: cellularValues?["CurrentNetworkType"] as? Int ?? 0)
    self.cellularLabel.text = "\(signalStrength)\n\(network)"
    
    let piValues: Dictionary<String, Any>? = values["pi"] as? Dictionary
    let cpuTemp: Int = Int(getDouble(value: piValues?["temp"]))
    let cpuActivity: Int = Int(getDouble(value: piValues?["cpu%"]))
    self.piLabel.text = "\(cpuTemp)C\n\(cpuActivity)%"

    let leftMotorValues: Dictionary<String, Any>? = values["lm"] as? Dictionary
    let leftTemp: Int = Int(getDouble(value: leftMotorValues?["temp"]))
    let rightMotorValues: Dictionary<String, Any>? = values["rm"] as? Dictionary
    let rightTemp: Int = Int(getDouble(value: rightMotorValues?["temp"]))
    self.motorTempLabel.text = "\(leftTemp)C\n\(rightTemp)C\n\(rightTemp)C"

    let batteryTemp: Int = Int(getDouble(value: batteryValues?["temp"]))
    self.generalLabel.text = "\(batteryTemp)C"
    
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
    self.phoneBatteryLabel.text = "\(batteryLevel)%\n\(batteryStatus)"
  }

}
