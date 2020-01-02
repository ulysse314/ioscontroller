import Foundation

class HullModule: Module {

  override func humanKey(key: String) -> String {
    if key == "T" {
      return "Temperature"
    } else if key == "prss" {
      return "Atmospheric pressure"
    } else if key == "hm" {
      return "Humidity"
    } else if key == "wtr" {
      return "Water"
    }
    return key
  }

}
