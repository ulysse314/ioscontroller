import Foundation

class BatteryModule: Module {
  
  override func value1() -> String? {
    return String(format: "%.1f", getDouble(value: self.values["volt"])) + "V"
  }
  
  override func value2() -> String? {
    return String(format: "%.1f", getDouble(value: self.values["amp"])) + "A"
  }

}
