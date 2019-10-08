import Foundation

class MotorDomain: ModuleDomain {
  
  init(identifier: DomainIdentifier) {
    super.init(name: "Motors", identifier: identifier)
  }

  // MARK: - Short values

  override func value1() -> String? {
    let module: Module? = self.module(name: "motor-l")
    let leftTemp: Int = Int(getDouble(value: module?.value(key: "temp")))
    return "\(leftTemp)ºC"
  }
  
  override func value2() -> String? {
    let module: Module? = self.module(name: "motor-r")
    let rightTemp: Int = Int(getDouble(value: module?.value(key: "temp")))
    return "\(rightTemp)ºC"
  }

}
