import Foundation

class MotorModule: Module {
  
  override func value1() -> String? {
    let leftMotorValues: Dictionary<String, Any>? = values["lm"] as? Dictionary
    let leftTemp: Int = Int(getDouble(value: leftMotorValues?["temp"]))
    return "\(leftTemp)C"
  }
  
  override func value2() -> String? {
    let rightMotorValues: Dictionary<String, Any>? = values["rm"] as? Dictionary
    let rightTemp: Int = Int(getDouble(value: rightMotorValues?["temp"]))
    return "\(rightTemp)C"
  }

  @objc func addValues(_ values: Dictionary<String, Any>, motorKey: String) {
  }

}
