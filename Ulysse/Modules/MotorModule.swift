import Foundation

class MotorModule: Module {

  override func humanKey(key: String) -> String {
    if key == "pwr" {
      return "Power %"
    } else if key == "t" {
      return "Temperature"
    }
    return key
  }

}
