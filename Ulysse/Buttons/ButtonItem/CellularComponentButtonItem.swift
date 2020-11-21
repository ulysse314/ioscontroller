import UIKit

class CellularComponentButtonItem: BoatComponentButtonItem {
  
  @objc init(boatComponents: Array<BoatComponent>) {
    super.init(boatComponents: boatComponents, name: "Cellular", identifier: .Cellular, image: UIImage.init(named: "cellular"))
  }

  // MARK: - Short values

  override func value1() -> String? {
    let boatComponent: BoatComponent? = self.boatComponent(identifier: .Cellular)
    return String(boatComponent?.value(key: "SignalIcon") as? Int ?? -1) + "/5"
  }
  
  override func value2() -> String? {
    let boatComponent: BoatComponent? = self.boatComponent(identifier: .Cellular)
    let value = boatComponent?.humanValue(key: "CurrentNetworkType", short: true)
    return value as? String ?? ""
  }

}
