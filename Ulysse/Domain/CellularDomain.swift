import Foundation

class CellularDomain: ModuleDomain {
  
  init(identifier: DomainIdentifier) {
    super.init(name: "Cellular", identifier: identifier)
  }
  
  // MARK: - Short values

  override func value1() -> String? {
    let module: Module? = self.module(name: "cellular")
    return String(module?.value(key: "SignalIcon") as? Int ?? -1) + "/5"
  }
  
  override func value2() -> String? {
    let module: Module? = self.module(name: "cellular")
    let value = module?.humanValue(key: "CurrentNetworkType", short: true)
    return value as? String ?? ""
  }
  
  override func createModule(name: String) -> Module {
    if name == "cellular" {
      return CellularModule(name: name)
    }
    return Module(name: name)
  }

}
