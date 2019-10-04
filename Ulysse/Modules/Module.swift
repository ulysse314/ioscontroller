import Foundation

@objc enum ModuleIdentifier: Int {
  case Battery
  case Cellular
  case GPS
  case Motors
  case Boat
  case Arduino
  case RaspberryPi
  case Settings
}

class Module: NSObject {

  @objc private(set) var name: String
  @objc let identifier: ModuleIdentifier
  @objc dynamic var values: Dictionary<String, Any> {
    didSet {
      var newErrors: Array<ModuleError> = []
      let valueErrors = self.values["errors"] as? Array<Array<Any>>
      if valueErrors != nil {
        for jsonError in valueErrors! {
          var error: ModuleError?
          if jsonError.count == 2 {
            error = ModuleError.createError(domainValue: jsonError[0], codeValue: jsonError[1], messageValue: nil)
          } else if jsonError.count == 3 {
            error = ModuleError.createError(domainValue: jsonError[0], codeValue: jsonError[1], messageValue: jsonError[2])
          }
          if error != nil {
            newErrors.append(error!)
          }
        }
      }
      self.errors = newErrors.count == 0 ? nil : newErrors

      var newKeys: Array = Array(self.values.keys)
      newKeys = newKeys.sorted{ $0.compare($1, options: .caseInsensitive) == .orderedAscending }
      self.keys = newKeys.filter { $0 != "errors" }
    }
  }
  @objc dynamic var errors: Array<ModuleError>?
  private(set) var keys: Array<String>

  @objc init(name: String, identifier: ModuleIdentifier) {
    self.name = name
    self.keys = [String]()
    self.values = [String: Any]()
    self.identifier = identifier
    super.init()
  }

  @objc func moduleValue(forKey key: String) -> Any? {
    let value: Any? = self.values[key]
    return value
  }

}
