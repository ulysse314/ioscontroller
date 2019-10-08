import Foundation

class BatteryDomain: ModuleDomain {
  
  init(identifier: DomainIdentifier) {
    super.init(name: "Battery", identifier: identifier)
  }

  // MARK: - Short values

  override func value1() -> String? {
    let module: Module? = self.module(name: "battery")
    return String(format: "%.1f", getDouble(value: module?.value(key: "volt"))) + "V"
  }
  
  override func value2() -> String? {
    let module: Module? = self.module(name: "battery")
    return String(format: "%.1f", getDouble(value: module?.value(key: "amp"))) + "A"
  }

}
