import Foundation

class ArduinoBoatComponent: BoatComponent {

  init() {
    super.init(name: "Arduino", identifier: .Arduino)
  }

  override func humanKey(key: String) -> String {
    if key == "ccldrt" {
      return "Cycle duration"
    } else if key == "cmp" {
      return "Compilation date"
    } else if key == "dbg" {
      return "Debug"
    } else if key == "expdrt" {
      return "Export duration"
    } else if key == "lpcnt" {
      return "Loop count"
    } else if key == "lpdrt" {
      return "Loop duration"
    } else if key == "mlls" {
      return "Millis"
    } else if key == "rf" {
      return "Free ram"
    } else if key == "rfd" {
      return "Free ram delta"
    } else if key == "stt" {
      return "Started"
    } else if key == "tst" {
      return "Timestamp"
    } else if key == "vrs" {
      return "Version"
    } else if key == "rst" {
      return "Last reset reason"
    }
    return key
  }

  override func humanValue(key: String, short: Bool) -> Any? {
    let value = super.humanValue(key: key, short: short)
    if key == "rst" {
      let intValue: Int = value as? Int ?? -1
      switch intValue {
      case 1:
        return "Power lost"
      case 32:
        return "Watchdog reset"
      case 64:
        return "Software update"
      default:
        return value
      }
    }
    return value
  }

}
