import UIKit

@objc enum ButtonItemIdentifier: Int {
  case Battery
  case Cellular
  case GPS
  case Motors
  case Hull
  case Arduino
  case RaspberryPi
  case Settings
}

class ButtonItem: NSObject {

  @objc let name: String
  @objc let identifier: ButtonItemIdentifier
  @objc let image: UIImage?
//  @objc var errors: Array<BoatComponentError> = [BoatComponentError]()

  @objc init(name: String, identifier: ButtonItemIdentifier, image: UIImage?) {
    self.name = name
    self.identifier = identifier
    self.image = image
    super.init()
  }
  
  // MARK: - Short values
  
  func value1() -> String? {
    return nil
  }
  
  func value2() -> String? {
    return nil
  }

  func errorCount() -> Int {
    return 0;
  }

}
