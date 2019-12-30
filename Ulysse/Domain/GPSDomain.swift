import Foundation

class GPSDomain: ModuleDomain {
  
  init(identifier: DomainIdentifier) {
    super.init(name: "GPS", identifier: identifier)
  }

  // MARK: - Short values

  override func value1() -> String? {
    let module: Module? = self.module(name: "gps")
    let modeValue: Int = module?.value(key: "mode") as? Int ?? 0
    switch modeValue {
    case 1:
      return "-"
    case 2:
      return "2D"
    case 3:
      return "3D"
    default:
      return "?"
    }
  }

  override func value2() -> String? {
    let module: Module? = self.module(name: "gps")
    let satCount: Int = module?.value(key: "sat") as? Int ?? 0
    let trackCount: Int = module?.value(key: "tracked") as? Int ?? 0
    return "\(trackCount)/\(satCount)"
  }

}
