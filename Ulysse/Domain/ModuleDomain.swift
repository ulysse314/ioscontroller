import Foundation

class ModuleDomain: Domain {

  class var ValuesUpdated: String {
    return "ValuesUpdated"
  }
  private var moduleAdded = false
  @objc private(set) var modules: Array<Module> = [Module]()
  @objc private var values: Dictionary<String, Dictionary<String, Any>> = [String: Dictionary<String, Any>]()
  private(set) var moduleKeys: Dictionary<String, Array<String>> = [String : Array<String>]()
  
  @objc func valueUpdateStart() {
    self.errors = [ModuleError]()
  }
  
  @objc func addValues(moduleName: String, values: Dictionary<String, Any>) {
    var module: Module? = self.module(name: moduleName)
    if module == nil {
      module = self.createModule(name: moduleName)
      self.modules.append(module!)
      self.moduleAdded = true
    }
    let valueErrors = values["errors"] as? Array<Array<Any>>
    if valueErrors != nil {
      for jsonError in valueErrors! {
        var error: ModuleError?
        if jsonError.count == 2 {
          error = ModuleError.createError(domainValue: jsonError[0], codeValue: jsonError[1], messageValue: nil)
        } else if jsonError.count == 3 {
          error = ModuleError.createError(domainValue: jsonError[0], codeValue: jsonError[1], messageValue: jsonError[2])
        }
        if error != nil {
          self.errors.append(error!)
        }
      }
    }
    module!.setAllValues(values)
  }

  @objc func valueUpdateDone() {
    if self.moduleAdded {
      self.modules.sort { $0.name < $1.name }
      self.moduleAdded = false
    }
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: ModuleDomain.ValuesUpdated), object:self)
  }

  // MARK: - Modules

  @objc func module(name: String) -> Module? {
    for module in self.modules {
      if module.name == name {
        return module
      }
    }
    return nil
  }
  
  func createModule(name: String) -> Module {
    if name == "cellular" {
      return CellularModule(name: name)
    } else if name == "gps" {
      return GPSModule(name: name)
    } else if name == "battery" {
      return BatteryModule(name: name)
    }
    return Module(name: name)
  }

}
