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
  }

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

  enum MotorError : Int {
    case noError = 0
    case temperatureUnknown = 1
    case temperatureInfo = 2
    case temperatureWarning = 3
    case temperatureCritical = 4
    case pwmNotAvailable = 5
  }

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

  class func errorMessage(error: Array<Int>) -> String {
    let domain: Domain? = Domain(rawValue: error[0])
    if domain == nil {
      return "Unknown domain"
    }
    let errorCode: Int = error[1]
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
}
