import Foundation

class Module: NSObject {

  @objc private(set) var name: String
  @objc dynamic var values: Dictionary<String, Any> {
    didSet {
      var newKeys: Array = Array(self.values.keys)
      newKeys = newKeys.sorted{ $0.compare($1, options: .caseInsensitive) == .orderedAscending }
      self.keys = newKeys.filter { $0 != "errors" }
    }
  }
  private(set) var keys: Array<String>

  @objc init(name: String) {
    self.name = name
    self.keys = [String]()
    self.values = [String: Any]()
    super.init()
  }

}
