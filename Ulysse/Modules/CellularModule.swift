import UIKit

class CellularModule: Module {

  @objc override func moduleValue(forKey key: String) -> Any? {
    let value = super.moduleValue(forKey:key)
    if key == "ConnectionStatus" {
      let status: Int = Int(value as? String ?? "-1")!
      if status == 2 || status == 3 || status == 5 || status == 8 || status == 20 || status == 21 || status == 23 || status == 27 || status == 28 || status == 29 || status == 30 || status == 31 || status == 32 || status == 33 {
        return "Connection failed, the profile is invalid"
      } else if status == 7 || status == 11 || status == 14 || status == 37 {
        return "Network access not allowed"
      } else if status == 12 || status == 13 {
        return "Connection failed, roaming not allowed"
      } else if status == 201 {
        return "Connection failed, bandwidth exceeded"
      } else if status == 900 {
        return "Connecting"
      } else if status == 901 {
        return "Connected"
      } else if status == 902 {
        return "Disconnected"
      } else if status == 903 {
        return "Disconnecting"
      } else if status == 904 {
        return "Connection failed or disabled"
      } else {
        return "Unknown " + String(status)
      }
    }
    return value
  }

}
