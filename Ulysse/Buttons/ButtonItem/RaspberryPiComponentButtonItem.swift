import UIKit

class RaspberryPiComponentButtonItem: BoatComponentButtonItem {
  
  @objc init(boatComponents: Array<BoatComponent>) {
    super.init(boatComponents: boatComponents, name: "Raspberry Pi", identifier: .RaspberryPi, image: UIImage.init(named: "raspberrypi"))
  }

  // MARK: - Short values

  override func value1() -> String? {
    let boatComponent: BoatComponent? = self.boatComponent(identifier: .RaspberryPi)
    let cpuTemp: Int = Int(getDouble(value: boatComponent?.value(key: "temp")).rounded())
    return "\(cpuTemp)ºC"
  }
  
  override func value2() -> String? {
    let boatComponent: BoatComponent? = self.boatComponent(identifier: .RaspberryPi)
    let cpuActivity: Int = Int(getDouble(value: boatComponent?.value(key: "cpu%")).rounded())
    return "\(cpuActivity)%"
  }

}
