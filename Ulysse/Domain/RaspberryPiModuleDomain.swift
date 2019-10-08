import Foundation

class RaspberryPiDomain: ModuleDomain {
  
  init(identifier: DomainIdentifier) {
    super.init(name: "Raspberry Pi", identifier: identifier)
  }

  // MARK: - Short values

  override func value1() -> String? {
    let module: Module? = self.module(name: "pi")
    let cpuTemp: Int = Int(getDouble(value: module?.value(key: "temp")))
    return "\(cpuTemp)ºC"
  }
  
  override func value2() -> String? {
    let module: Module? = self.module(name: "pi")
    let cpuActivity: Int = Int(getDouble(value: module?.value(key: "cpu%")))
    return "\(cpuActivity)%"
  }

}
