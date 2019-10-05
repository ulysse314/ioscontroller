import Foundation

class GPSModule: Module {
  
  override func value1() -> String? {
    return nil
  }
  
  override func value2() -> String? {
    let satCount: Int = self.values["sat"] as? Int ?? 0
    let trackCount: Int = self.values["tracked"] as? Int ?? 0
    return "\(trackCount)/\(satCount)"
  }

}
