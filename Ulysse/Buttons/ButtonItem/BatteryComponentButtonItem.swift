import UIKit

class BatteryComponentButtonItem: BoatComponentButtonItem {
  
  @objc init(boatComponents: Array<BoatComponent>) {
    super.init(boatComponents: boatComponents, name: "Battery", identifier: .Battery, image: UIImage.init(named: "battery"))
  }

  // MARK: - Short values

  override func value1() -> String? {
    let boatComponent: BoatComponent? = self.boatComponent(identifier: .Battery)
    return String(format: "%.1f", getDouble(value: boatComponent?.value(key: "volt"))) + "V"
  }
  
  override func value2() -> String? {
    let boatComponent: BoatComponent? = self.boatComponent(identifier: .Battery)
    return String(format: "%.1f", getDouble(value: boatComponent?.value(key: "amp"))) + "A"
  }

}
