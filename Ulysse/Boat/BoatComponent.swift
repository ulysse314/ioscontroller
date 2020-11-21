import Foundation

class BoatComponent: NSObject {

  @objc enum BoatComponentIdentifier: Int {
    case Arduino
    case Battery
    case Cellular
    case GPS
    case Hull
    case LeftMotor
    case RightMotor
    case RaspberryPi
    case Settings
  }

  @objc let name: String
  @objc let identifier: BoatComponentIdentifier
  @objc private(set) var sortedKeys: Array<String> = [String]()
  @objc private(set) var values: Dictionary<String, Any> = [String: Any]()
  @objc private(set) var errors: Array<BoatComponentError> = [BoatComponentError]()
  
  init(name: String, identifier: BoatComponentIdentifier) {
    self.name = name
    self.identifier = identifier
    super.init()
  }

  @objc func setAllValues(_ values: Dictionary<String, Any>) {
    self.values = values
    var newSortedKeys: Array = Array(self.values.keys)
    newSortedKeys = newSortedKeys.sorted{ $0.compare($1, options: .caseInsensitive) == .orderedAscending }
    self.sortedKeys = newSortedKeys.filter { $0 != "err" }
    self.values.removeValue(forKey: "err")
    self.errors.removeAll()
    let valueErrors = values["err"] as? Array<Array<Any>>
    if valueErrors != nil {
      for jsonError in valueErrors! {
        // jsonError[0]: Domain
        // jsonError[1]: Error code
        // jsonError[2]: Persistant
        // jsonError[3]: Message
        var error: BoatComponentError?
        if jsonError.count >= 4 {
          error = BoatComponentError.createError(domainValue: jsonError[0], codeValue: jsonError[1], messageValue: jsonError[3])
        } else if jsonError.count >= 2 {
          error = BoatComponentError.createError(domainValue: jsonError[0], codeValue: jsonError[1], messageValue: nil)
        }
        if error != nil {
          self.errors.append(error!)
        }
      }
    }
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Boat.UpdatedValueNotificationName), object:self)
  }

  func value(key: String) -> Any? {
    return self.values[key]
  }

  func humanValue(key: String, short: Bool) -> Any? {
    return self.value(key: key)
  }

  func humanKey(key: String) -> String {
    return key
  }

}
