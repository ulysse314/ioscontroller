import Foundation

class ArduinoModule: Module {

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
    }
    return key
  }

}
