import Foundation

class BatteryModule: Module {

  override func humanKey(key: String) -> String {
    if key == "batT" {
      return "Battery temperature"
    } else if key == "balT" {
      return "Balancer temperature"
    } else if key == "amp" {
      return "Ampere"
    } else if key == "bal0" {
      return "Balancer 0"
    } else if key == "bal1" {
      return "Balancer 1"
    } else if key == "bal2" {
      return "Balancer 2"
    } else if key == "volt" {
      return "Volt"
    } else if key == "ah" {
      return "Consumption"
    }
    return key
  }

}
