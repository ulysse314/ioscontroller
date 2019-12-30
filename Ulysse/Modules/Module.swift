import Foundation

class Module: NSObject {

  @objc let name: String
  @objc private(set) var sortedKeys: Array<String> = [String]()
  @objc private(set) var values: Dictionary<String, Any> = [String: Any]()
  
  init(name: String) {
    self.name = name
    super.init()
  }

  func setAllValues(_ values: Dictionary<String, Any>) {
    self.values = values
    var newSortedKeys: Array = Array(self.values.keys)
    newSortedKeys = newSortedKeys.sorted{ $0.compare($1, options: .caseInsensitive) == .orderedAscending }
    self.sortedKeys = newSortedKeys.filter { $0 != "errors" }
    self.values.removeValue(forKey: "errors")
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
