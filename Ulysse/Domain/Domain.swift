import Foundation

@objc enum DomainIdentifier: Int {
  case Battery
  case Cellular
  case GPS
  case Motors
  case Boat
  case Arduino
  case RaspberryPi
  case Settings
}

class Domain: NSObject {

  @objc let name: String
  @objc let identifier: DomainIdentifier
  @objc var errors: Array<ModuleError> = [ModuleError]()

  @objc init(name: String, identifier: DomainIdentifier) {
    self.name = name
    self.identifier = identifier
    super.init()
  }
  
  // MARK: - Short values
  
  func value1() -> String? {
    return nil
  }
  
  func value2() -> String? {
    return nil
  }

}
