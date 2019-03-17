//
//  ModuleError.swift
//  Ulysse
//
//  Copyright © 2019 Ulysse 314 Boat. All rights reserved.
//

import UIKit

class ModuleError: NSObject {
  enum Domain : Int {
    case none = 0
    case arduino = 1
    case gps = 2
    case motor = 3
    case battery = 4
    case cellular = 5
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
    case lowMemory = 10
    case veryLowMemory = 11
    case codeUnknown = 12
    case gpsValueIndex = 13
    case gpsCodeUnknown = 14
    case addingValueWithSameName = 15
    case pwmDriverNotAvailable = 16
    case piLinkConnectionTimeOut = 17
    case loopCycleLowInfo = 18
    case loopCycleLowWarning = 19
    case loopCycleLowCritical = 20
    case notStarted = 21
  }

  // GPS domain 2
  enum GPSError : Int {
    case noError = 0
    case unknownAntenna = 1
    case externalAntennaProblem = 2
    case internalAntenna = 3
    case noFixMode = 4
    case mode2D = 5
    case usedSatellitesTooLow = 6
    case usedSatellitesLow = 7
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
    case codeUnknown = 1
    case INA219NotFound = 2
    case voltageInfo = 3
    case voltageWarning = 4
    case voltageCritical = 5
    case ampereInfo = 6
    case ampereWarning = 7
    case ampereCritical = 8
    case temperatureUnknown = 9
    case temperatureInfo = 10
    case temperatureWarning = 11
    case temperatureCritical = 12
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
  }

  class func errorMessage(error: Array<Any>) -> String {
    let domain: Domain? = Domain(rawValue: error[0] as! Int)
    if domain == nil {
      return "Unknown domain"
    }
    let errorCode: Int = error[1] as! Int
    switch domain! {
    case .none:
      return "No domain"
    case .arduino:
      return arduinoErrorMessage(errorCode: ArduinoError(rawValue: errorCode))
    case .gps:
      return gpsErrorMessage(errorCode: GPSError(rawValue: errorCode))
    case .motor:
      return motorErrorMessage(errorCode: MotorError(rawValue: errorCode))
    case .battery:
      return batteryErrorMessage(errorCode: BatteryError(rawValue: errorCode))
    case .cellular:
      return "Test"
    }
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
      return "Compute time info"
    case .computeTimeWarning:
      return "Compute time warning"
    case .computeTimeCritical:
      return "Compute time critical"
    case .memoryDifference100:
      return "Memory difference 100"
    case .memoryDifference500:
      return "Memory difference 500"
    case .memoryDifference1k:
      return "Memory difference 1k"
    case .infoMemory:
      return "Info memory"
    case .lowMemory:
      return "Low memory"
    case .veryLowMemory:
      return "Very low memory"
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
    case .loopCycleLowInfo:
      return "Loop cycle low info"
    case .loopCycleLowWarning:
      return "Loop cycle low warning"
    case .loopCycleLowCritical:
      return "Loop cycle low critical"
    case .notStarted:
      return "Not started"
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
    case .internalAntenna:
      return "Internal antenna"
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

  class func motorErrorMessage(errorCode: MotorError?) -> String {
    if errorCode == nil {
      return "Unknown motor error code"
    }
    switch errorCode! {
    case .noError:
      return "No error"
    case .temperatureUnknown:
      return "Temperature unknown"
    case .temperatureInfo:
      return "Temperature info"
    case .temperatureWarning:
      return "Temperature warning"
    case .temperatureCritical:
      return "Temperature critical"
    case .pwmNotAvailable:
      return "PWM not available"
    }
  }

  class func batteryErrorMessage(errorCode: BatteryError?) -> String {
    if errorCode == nil {
      return "Unknown motor error code"
    }
    switch errorCode! {
    case .noError:
      return "No error"
    case .codeUnknown:
      return "Code unknown"
    case .INA219NotFound:
      return "INA219 not found"
    case .voltageInfo:
      return "Voltage info"
    case .voltageWarning:
      return "Voltage warning"
    case .voltageCritical:
      return "Voltage critical"
    case .ampereInfo:
      return "Ampere info"
    case .ampereWarning:
      return "Ampere warning"
    case .ampereCritical:
      return "Ampere critical"
    case .temperatureUnknown:
      return "Temperature unknown"
    case .temperatureInfo:
      return "Temperture info"
    case .temperatureWarning:
      return "Temperature warning"
    case .temperatureCritical:
      return "Temperature critical"
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
      self.message = ModuleError.motorErrorMessage(errorCode: MotorError(rawValue: errorCode))
    case .battery:
      self.message = ModuleError.batteryErrorMessage(errorCode: BatteryError(rawValue: errorCode))
    case .cellular:
      self.message = ModuleError.cellularErrorMessage(errorCode: CellularError(rawValue: errorCode), message: message)
    }
  }
}
