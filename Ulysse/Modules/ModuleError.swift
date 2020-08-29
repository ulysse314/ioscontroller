import UIKit

class ModuleError: NSObject {
  enum Domain : Int {
    case none = 0
    case arduino = 1
    case gps = 2
    case motor = 3
    case battery = 4
    case cellular = 5
    case pi = 6
    case hull = 7
  }

  // Arduino domain 1
  enum ArduinoError : Int {
    case noError = 0
    case setValueWithWrongType = 1
    case getValueWithWrongType = 2
    case computeTimeInfo = 3
    case computeTimeWarning = 4
    case computeTimeCritical = 5
    case memoryDifference100 = 6
    case memoryDifference500 = 7
    case memoryDifference1k = 8
    case infoMemory = 9
    case warningMemory = 10
    case criticalMemory = 11
    case codeUnknown = 12
    case gpsValueIndex = 13
    case gpsCodeUnknown = 14
    case addingValueWithSameName = 15
    case pwmDriverNotAvailable = 16
    case piLinkConnectionTimeOut = 17
    case mainLoopCounterLowInfo = 18
    case mainLoopCounterLowWarning = 19
    case mainLoopCounterLowCritical = 20
    case notStarted = 21
    case motorCodeUnknown = 22
    case batteryCodeUnknown = 23
    case devNotFound = 100
    case connectionError = 101
    case noDataError = 102
  }

  // GPS domain 2
  enum GPSError : Int {
    case noError = 0
    case unknownAntenna = 1
    case externalAntennaProblem = 2
    case usingInternalAntenna = 3
    case unknownMode = 4
    case noFixMode = 5
    case mode2D = 6
    case usedSatellitesTooLow = 7
    case usedSatellitesLow = 8
  }

  // Motor domain 3
  enum MotorError : Int {
    case noError = 0
    case temperatureUnknown = 1
    case temperatureInfo = 2
    case temperatureWarning = 3
    case temperatureCritical = 4
    case pwmNotAvailable = 5
  }

  // Battery domain 4
  enum BatteryError : Int {
    case noError = 0
    case INA219NotFound = 1
    case voltageInfo = 2
    case voltageWarning = 3
    case voltageCritical = 4
    case ampereInfo = 5
    case ampereWarning = 6
    case ampereCritical = 7
    case batteryTemperatureUnknown = 8
    case batteryTemperatureInfo = 9
    case batteryTemperatureWarning = 10
    case batteryTemperatureCritical = 11
    case ads1115NotFound = 12
    case balancerTemperatureUnknown = 13
    case balancerTemperatureInfo = 14
    case balancerTemperatureWarning = 15
    case balancerTemperatureCritical = 16
  }

  // Cellular domain 5
  enum CellularError : Int {
    case noError = 0
    case genericError = 1
    case noInterface = 2
    case signalURLFailed = 3
    case statusURLFailed = 4
    case trafficStatURLFailed = 5
    case NotConnected = 6
    case LowSignal = 7
    case VeryLowSignal = 8
    case SimLocked = 9
  }

  // Pi domain 6
  enum PiError : Int {
    case noError = 0
    case temperatureInfo = 1
    case temperatureWarning = 2
    case temperatureCritical = 3
    case memoryInfo = 4
    case memoryWarning = 5
    case memoryCritical = 6
    case percentageDiskInfo = 7
    case percentageDiskWarning = 8
    case percentageDiskCritical = 9
    case percentageCPUInfo = 10
    case percentageCPUWarning = 11
    case percentageCPUCritical = 12
  }

  // Hull domain 7
  enum HullError : Int {
    case noError = 0
    case ads1115NotFound = 1
    case leak = 2
    case temperatureInfo = 3
    case temperatureWarning = 4
    case temperatureCritical = 5
    case temperatureInvalid = 6
    case bno055Error = 7
    case bno055SystemStatus = 8
    case bno055SelfTest = 9
    case bno055AccelCalibration = 10
    case bno055GyroCalibration = 11
    case bno055MagCalibration = 12
    case bno055SysCalibration = 13
  }

  class func arduinoErrorMessage(errorCode: ArduinoError?) -> String {
    if errorCode == nil {
      return "Unknown arduino error code"
    }
    switch errorCode! {
    case .noError:
      return "No error"
    case .setValueWithWrongType:
      return "Set value with wrong type"
    case .getValueWithWrongType:
      return "Get value with type"
    case .computeTimeInfo:
      return "[info] Compute time"
    case .computeTimeWarning:
      return "[warning] Compute time"
    case .computeTimeCritical:
      return "[critical] Compute time"
    case .memoryDifference100:
      return "Memory difference 100"
    case .memoryDifference500:
      return "Memory difference 500"
    case .memoryDifference1k:
      return "Memory difference 1k"
    case .infoMemory:
      return "[info] memory"
    case .warningMemory:
      return "[warning] memory"
    case .criticalMemory:
      return "[critical] memory"
    case .codeUnknown:
      return "Code unknown"
    case .gpsValueIndex:
      return "GPS value index"
    case .gpsCodeUnknown:
      return "GPS code unknown"
    case .addingValueWithSameName:
      return "Adding value with same name"
    case .pwmDriverNotAvailable:
      return "PWM driver not available"
    case .piLinkConnectionTimeOut:
      return "PI link connection time out"
    case .mainLoopCounterLowInfo:
      return "[info] Main loop counter low"
    case .mainLoopCounterLowWarning:
      return "[warning] Main loop counter low"
    case .mainLoopCounterLowCritical:
      return "[critical] Main loop counter low"
    case .notStarted:
      return "Not started"
    case .motorCodeUnknown:
      return "Motor code unknown"
    case .batteryCodeUnknown:
      return "Battery code unknown"
    case .devNotFound:
      return "Dev not found"
    case .connectionError:
      return "Connection error"
    case .noDataError:
      return "No data"
    }
  }

  class func gpsErrorMessage(errorCode: GPSError?) -> String {
    if errorCode == nil {
      return "Unknown GPS error code"
    }
    switch errorCode! {
    case .noError:
      return "No error"
    case .unknownAntenna:
      return "Unknown antenna"
    case .externalAntennaProblem:
      return "External antenna problem"
    case .usingInternalAntenna:
      return "Using internal antenna"
    case .unknownMode:
      return "Unknown mode"
    case .noFixMode:
      return "No fix mode"
    case .mode2D:
      return "2D mode"
    case .usedSatellitesTooLow:
      return "Used satellites too low"
    case .usedSatellitesLow:
      return "Used satellites low"
    }
  }

  class func motorErrorMessage(errorCode: MotorError?, message: String?) -> String {
    if errorCode == nil {
      return "Unknown motor error code"
    }
    switch errorCode! {
    case .noError:
      return "No error" + (message != nil ? (", " + message!) : "")
    case .temperatureUnknown:
      return "Temperature unknown" + (message != nil ? (", " + message!) : "")
    case .temperatureInfo:
      return "[info] Temperature" + (message != nil ? (", " + message!) : "")
    case .temperatureWarning:
      return "[warning] Temperature" + (message != nil ? (", " + message!) : "")
    case .temperatureCritical:
      return "[critical] Temperature" + (message != nil ? (", " + message!) : "")
    case .pwmNotAvailable:
      return "PWM not available" + (message != nil ? (", " + message!) : "")
    }
  }

  class func batteryErrorMessage(errorCode: BatteryError?) -> String {
    if errorCode == nil {
      return "Unknown motor error code"
    }
    switch errorCode! {
    case .noError:
      return "No error"
    case .INA219NotFound:
      return "INA219 not found"
    case .voltageInfo:
      return "[info] Voltage"
    case .voltageWarning:
      return "[warning] Voltage"
    case .voltageCritical:
      return "[critical] Voltage"
    case .ampereInfo:
      return "[info] Ampere"
    case .ampereWarning:
      return "[warning] Ampere"
    case .ampereCritical:
      return "[critical] Ampere"
    case .batteryTemperatureUnknown:
      return "Battery temperature unknown"
    case .batteryTemperatureInfo:
      return "[info] Battery temperture"
    case .batteryTemperatureWarning:
      return "[warning] Battery temperature"
    case .batteryTemperatureCritical:
      return "[critical] Battery temperature"
    case .ads1115NotFound:
      return "[critical] ADS1115 not found"
    case .balancerTemperatureUnknown:
      return "Balancer temperature unknown"
    case .balancerTemperatureInfo:
      return "[info] Balancer temperture"
    case .balancerTemperatureWarning:
      return "[warning] Balancer temperature"
    case .balancerTemperatureCritical:
      return "[critical] Balancer temperature"
    }
  }

  class func cellularErrorMessage(errorCode: CellularError?, message: String?) -> String {
    if errorCode == nil {
      return "Unknown motor error code"
    }
    switch errorCode! {
    case .noError:
      return "No error" + (message != nil ? (", " + message!) : "")
    case .genericError:
      return "Generic error" + (message != nil ? (", " + message!) : "")
    case .noInterface:
      return "No interface" + (message != nil ? (", " + message!) : "")
    case .signalURLFailed:
      return "Signal URL failed" + (message != nil ? (", " + message!) : "")
    case .statusURLFailed:
      return "Status URL failed" + (message != nil ? (", " + message!) : "")
    case .trafficStatURLFailed:
      return "Traffic statistic URL failed" + (message != nil ? (", " + message!) : "")
    case .NotConnected:
      return "Not connected" + (message != nil ? (", " + message!) : "")
    case .LowSignal:
      return "Low signal" + (message != nil ? (", " + message!) : "")
    case .VeryLowSignal:
      return "Very low signal" + (message != nil ? (", " + message!) : "")
    case .SimLocked:
      return "Sim locked" + (message != nil ? (", " + message!) : "")
    }
  }

  class func piErrorMessage(errorCode: PiError?, message: String?) -> String {
    if errorCode == nil {
      return "Unknown pi error code"
    }
    switch errorCode! {
    case .noError:
      return "No error" + (message != nil ? (", " + message!) : "")
    case .temperatureInfo:
      return "[info] Temperature" + (message != nil ? (", " + message!) : "")
    case .temperatureWarning:
      return "[warning] Temperature" + (message != nil ? (", " + message!) : "")
    case .temperatureCritical:
      return "[critical] Temperature" + (message != nil ? (", " + message!) : "")
    case .memoryInfo:
      return "[info] Memory" + (message != nil ? (", " + message!) : "")
    case .memoryWarning:
      return "[warning] Memory" + (message != nil ? (", " + message!) : "")
    case .memoryCritical:
      return "[critical] Memory" + (message != nil ? (", " + message!) : "")
    case .percentageDiskInfo:
      return "[info] Disk percentage" + (message != nil ? (", " + message!) : "")
    case .percentageDiskWarning:
      return "[warning] Disk percentage" + (message != nil ? (", " + message!) : "")
    case .percentageDiskCritical:
      return "[critical] Disk percentage" + (message != nil ? (", " + message!) : "")
    case .percentageCPUInfo:
      return "[info] CPU percentage" + (message != nil ? (", " + message!) : "")
    case .percentageCPUWarning:
      return "[warning] CPU percentage" + (message != nil ? (", " + message!) : "")
    case .percentageCPUCritical:
      return "[critical] CPU percentage" + (message != nil ? (", " + message!) : "")
    }
  }

  class func hullErrorMessage(errorCode: HullError?, message: String?) -> String {
    if errorCode == nil {
      return "Unknown hull error code"
    }
    switch errorCode! {
    case .noError:
      return "No error" + (message != nil ? (", " + message!) : "")
    case .ads1115NotFound:
      return "[info] ADS1115 not found" + (message != nil ? (", " + message!) : "")
    case .leak:
      return "[critical] Leak" + (message != nil ? (", " + message!) : "")
    case .temperatureInfo:
      return "[info] Temperature" + (message != nil ? (", " + message!) : "")
    case .temperatureWarning:
      return "[warning] Temperature" + (message != nil ? (", " + message!) : "")
    case .temperatureCritical:
      return "[critical] Temperature" + (message != nil ? (", " + message!) : "")
    case .temperatureInvalid:
      return "[critical] Temperature Invalid" + (message != nil ? (", " + message!) : "")
    case .bno055Error:
      return "[critical] BNO055 error" + (message != nil ? (", " + message!) : "")
    case .bno055SystemStatus:
      return "[critical] BNO055 system status" + (message != nil ? (", " + message!) : "")
    case .bno055SelfTest:
      return "[warning] BNO055 self test error" + (message != nil ? (", " + message!) : "")
    case .bno055AccelCalibration:
      return "[warning] BNO055 accelerometer calibration" + (message != nil ? (", " + message!) : "")
    case .bno055GyroCalibration:
      return "[warning] BNO055 gyroscope calibration" + (message != nil ? (", " + message!) : "")
    case .bno055MagCalibration:
      return "[warning] BNO055 magnetometer calibration" + (message != nil ? (", " + message!) : "")
    case .bno055SysCalibration:
      return "[warning] BNO055 system calibration" + (message != nil ? (", " + message!) : "")
    }
  }

  var domain: Domain
  var errorCode: Int
  var message: String

  class func createError(domainValue: Any, codeValue: Any, messageValue: Any?) -> ModuleError? {
    var domain: Domain?
    if domainValue is Int {
      domain = Domain(rawValue: domainValue as! Int)
    }
    let code: Int? = codeValue as? Int
    let message: String? = messageValue as? String
    if domain != nil && code != nil {
      return ModuleError(domain: domain!, errorCode: code!, message: message)
    }
    return nil
  }

  init(domain: Domain, errorCode: Int, message: String?) {
    self.domain = domain
    self.errorCode = errorCode
    switch self.domain {
    case .none:
      self.message = "No domain"
    case .arduino:
      self.message = ModuleError.arduinoErrorMessage(errorCode: ArduinoError(rawValue: errorCode))
    case .gps:
      self.message = ModuleError.gpsErrorMessage(errorCode: GPSError(rawValue: errorCode))
    case .motor:
      self.message = ModuleError.motorErrorMessage(errorCode: MotorError(rawValue: errorCode), message: message)
    case .battery:
      self.message = ModuleError.batteryErrorMessage(errorCode: BatteryError(rawValue: errorCode))
    case .cellular:
      self.message = ModuleError.cellularErrorMessage(errorCode: CellularError(rawValue: errorCode), message: message)
    case .pi:
      self.message = ModuleError.piErrorMessage(errorCode: PiError(rawValue: errorCode), message: message)
    case .hull:
      self.message = ModuleError.hullErrorMessage(errorCode: HullError(rawValue: errorCode), message: message)
    }
  }
}
