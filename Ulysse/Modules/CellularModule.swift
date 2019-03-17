import UIKit

class CellularModule: Module {

  @objc override func moduleValue(forKey key: String) -> Any? {
    let value = super.moduleValue(forKey:key)
    if key == "ConnectionStatus" {
      let status: Int = Int(value as? String ?? "-1")!
      return type(of: self).connectionStatusString(status: status)
    } else if key == "CurrentNetworkType" {
      let connectionType: Int = Int(value as? String ?? "-1")!
      return type(of: self).networkTypeString(connectionType: connectionType)
    }
    return value
  }

  class func connectionStatusString(status: Int) -> String {
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

  class func networkTypeString(connectionType: Int) -> String {
    if connectionType == 0 {
      return "No Service"
    } else if connectionType == 1 {
      return "GSM"
    } else if connectionType == 2 {
      return "GPRS (2.5G)"
    } else if connectionType == 3 {
      return "EDGE (2.75G)"
    } else if connectionType == 4 {
      return "WCDMA (3G)"
    } else if connectionType == 5 {
      return "HSDPA (3G)"
    } else if connectionType == 6 {
      return "HSUPA (3G)"
    } else if connectionType == 7 {
      return "HSPA (3G)"
    } else if connectionType == 8 {
      return "TD-SCDMA (3G)"
    } else if connectionType == 9 {
      return "HSPA+ (4G)"
    } else if connectionType == 10 {
      return "EV-DO rev. 0"
    } else if connectionType == 11 {
      return "EV-DO rev. A"
    } else if connectionType == 12 {
      return "EV-DO rev. B"
    } else if connectionType == 13 {
      return "1xRTT"
    } else if connectionType == 14 {
      return "UMB"
    } else if connectionType == 15 {
      return "1xEVDV"
    } else if connectionType == 16 {
      return "3xRTT"
    } else if connectionType == 17 {
      return "HSPA+ 64QAM"
    } else if connectionType == 18 {
      return "HSPA+ MIMO"
    } else if connectionType == 19 {
      return "LTE (4G)"
    } else if connectionType == 41 {
      return "UMTS (3G)"
    } else if connectionType == 44 {
      return "HSPA (3G)"
    } else if connectionType == 45 {
      return "HSPA+ (3G)"
    } else if connectionType == 46 {
      return "DC-HSPA+ (3G)"
    } else if connectionType == 64 {
      return "HSPA (3G)"
    } else if connectionType == 65 {
      return "HSPA+ (3G)"
    } else if connectionType == 101 {
      return "LTE (4G)"
    } else {
      return "Unknown: " + String(connectionType)
    }
  }
}
