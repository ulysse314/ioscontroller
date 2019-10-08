import Foundation

class GPSDomain: ModuleDomain {
  
  init(identifier: DomainIdentifier) {
    super.init(name: "GPS", identifier: identifier)
  }

  // MARK: - Short values

  override func value2() -> String? {
    let module: Module? = self.module(name: "gps")
    let satCount: Int = module?.value(key: "sat") as? Int ?? 0
    let trackCount: Int = module?.value(key: "tracked") as? Int ?? 0
    return "\(trackCount)/\(satCount)"
  }

}
