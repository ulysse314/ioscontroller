import Foundation

class GPSDomain: ModuleDomain {
  
  init(identifier: DomainIdentifier) {
    super.init(name: "GPS", identifier: identifier)
  }

  // MARK: - Short values

  override func value1() -> String? {
    let module: Module? = self.module(name: "gps")
    let modeValue: Int = module?.value(key: "mod") as? Int ?? 0
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
    let usedSatelliteCount: Int = module?.value(key: "ust") as? Int ?? 0
    let viewedSatelliteCount: Int = module?.value(key: "vst") as? Int ?? 0
    return "\(usedSatelliteCount)/\(viewedSatelliteCount)"
  }

}
