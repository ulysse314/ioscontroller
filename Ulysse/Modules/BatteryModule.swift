import Foundation

class BatteryModule: Module {

  override func humanKey(key: String) -> String {
    if key == "batT" {
      return "battery temperature"
    } else if key == "balT" {
      return "balancer temperature"
    }
    return key
  }

}
