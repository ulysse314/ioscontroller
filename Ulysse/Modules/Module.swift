import Foundation

class Module: NSObject {

  @objc private(set) var name: String
  @objc dynamic var values: Dictionary<String, Any> {
    didSet {
      self.errors = self.values["errors"] as? Array<Array<Int>>
      var newKeys: Array = Array(self.values.keys)
      newKeys = newKeys.sorted{ $0.compare($1, options: .caseInsensitive) == .orderedAscending }
      self.keys = newKeys.filter { $0 != "errors" }
    }
  }
  @objc dynamic var errors: Array<Array<Int>>? {
    didSet {
      if self.errors != nil {
        self.errorMessages = []
        for error in self.errors! {
          self.errorMessages!.append(ModuleError.errorMessage(error: error))
        }
      } else {
        self.errorMessages = nil
      }
    }
  }
  @objc dynamic var errorMessages: Array<String>?
  private(set) var keys: Array<String>

  @objc init(name: String) {
    self.name = name
    self.keys = [String]()
    self.values = [String: Any]()
    super.init()
  }

}
