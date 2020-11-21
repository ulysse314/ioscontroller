import UIKit

class GPSComponentButtonItem: BoatComponentButtonItem {
  
  @objc init(boatComponents: Array<BoatComponent>) {
    super.init(boatComponents: boatComponents, name: "GPS", identifier: .GPS, image: UIImage.init(named: "satellite"))
  }

  // MARK: - Short values

  override func value1() -> String? {
    let boatComponent: BoatComponent? = self.boatComponent(identifier: .GPS)
    let modeValue: Int = boatComponent?.value(key: "mod") as? Int ?? 0
    switch modeValue {
    case 1:
      return "-"
    case 2:
      return "2D"
    case 3:
      return "3D"
    default:
      return "?"
    }
  }

  override func value2() -> String? {
    let boatComponent: BoatComponent? = self.boatComponent(identifier: .GPS)
    let usedSatelliteCount: Int = boatComponent?.value(key: "ust") as? Int ?? 0
    let viewedSatelliteCount: Int = boatComponent?.value(key: "vst") as? Int ?? 0
    return "\(usedSatelliteCount)/\(viewedSatelliteCount)"
  }

}
