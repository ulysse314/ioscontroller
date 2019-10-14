import Foundation

class GPSModule: Module {

  override func humanValue(key: String, short: Bool) -> Any? {
    let value = super.humanValue(key: key, short: short)
    if key == "antenna" {
      let intValue: Int = value as? Int ?? 0;
      switch intValue {
      case 1:
        return "External antenna problem"
      case 2:
        return "Using internal"
      case 3:
        return "Using external"
      default:
        return value
      }
    } else if key == "mode" {
      let intValue: Int = value as? Int ?? 0
      switch intValue {
      case 1:
        return "No fix"
      case 2:
        return "2D fix"
      case 3:
        return "3D fix"
      default:
        return value
      }
    } else if key == "fixquality" {
      let intValue: Int = value as? Int ?? -1
      switch intValue {
      case 0:
        return "Invalid"
      case 1:
        return "GPS fix"
      case 2:
        return "DGPS fix"
      case 3:
        return "PPS fix"
      case 4:
        return "Real Time Kinematic"
      case 5:
        return "Float RTK"
      case 6:
        return "Estimated (Dead reckoning)"
      case 7:
        return "Manual input mode"
      case 8:
        return "Simulation mode"
      default:
        return value
      }
    }

    return value
  }

}
