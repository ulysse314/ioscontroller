import Foundation

class HullDomain: ModuleDomain {

  init(identifier: DomainIdentifier) {
    super.init(name: "Hull", identifier: identifier)
  }

  // MARK: - Short values

  override func value1() -> String? {
    let module: Module? = self.module(name: "hull")
    let temperature: Int = Int(getDouble(value: module?.value(key: "T")))
    return "\(temperature)ºC"
  }

  override func value2() -> String? {
    let module: Module? = self.module(name: "hull")
    let humidity: Int = Int(getDouble(value: module?.value(key: "hm")))
    return "\(humidity)%"
  }

}
