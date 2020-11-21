import Foundation

class MotorBoatComponent: BoatComponent {

  override func humanKey(key: String) -> String {
    if key == "pwr" {
      return "Power %"
    } else if key == "t" {
      return "Temperature"
    }
    return key
  }

}
