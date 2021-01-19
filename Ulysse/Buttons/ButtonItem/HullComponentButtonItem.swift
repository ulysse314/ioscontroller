import UIKit

class HullComponentButtonItem: BoatComponentButtonItem {

  @objc init(boatComponents: Array<BoatComponent>) {
    super.init(boatComponents: boatComponents, name: "Hull", identifier: .Hull, image: UIImage.init(named: "boat"))
  }

  // MARK: - Short values

  override func value1() -> String? {
    let boatComponent: BoatComponent? = self.boatComponent(identifier: .Hull)
    let temperature: Int = Int(getDouble(value: boatComponent?.value(key: "T")).rounded())
    return "\(temperature)ºC"
  }

  override func value2() -> String? {
    let boatComponent: BoatComponent? = self.boatComponent(identifier: .Hull)
    let humidity: Int = Int(getDouble(value: boatComponent?.value(key: "hm")).rounded())
    return "\(humidity)%"
  }

}
