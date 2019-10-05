import Foundation

class RaspberryPiModule: Module {
  
  override func value1() -> String? {
    let cpuTemp: Int = Int(getDouble(value: self.values["temp"]))
    return "\(cpuTemp)C"
  }
  
  override func value2() -> String? {
    let cpuActivity: Int = Int(getDouble(value: self.values["cpu%"]))
    return "\(cpuActivity)%"
  }

}
