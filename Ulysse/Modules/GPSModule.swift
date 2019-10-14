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
      let intValue: Int = value as? Int ?? 0;
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
    }

    return value
  }

}
