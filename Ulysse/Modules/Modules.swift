//
//  Modules.swift
//  Ulysse
//
//  Copyright © 2019 Ulysse 314 Boat. All rights reserved.
//

import Foundation

class Modules: NSObject {
  
  @objc var batteryModule: BatteryModule
  @objc var cellularModule: CellularModule
  @objc var gpsModule: GPSModule
  @objc var motorsModule: MotorModule
  @objc var boatModule: Module
  @objc var arduinoModule: Module
  @objc var raspberryPiModule: RaspberryPiModule
  @objc var settings: Module

  override init() {
    self.batteryModule = BatteryModule(name: "Battery", identifier: .Battery)
    self.cellularModule = CellularModule(name: "4G Connection", identifier: .Cellular)
    self.gpsModule = GPSModule(name: "GPS", identifier: .GPS)
    self.motorsModule = MotorModule(name: "Motors", identifier: .Motors)
    self.boatModule = Module(name: "Boat", identifier: .Boat)
    self.arduinoModule = Module(name: "Arduino", identifier: .Arduino)
    self.raspberryPiModule = RaspberryPiModule(name: "Raspberry PI", identifier: .RaspberryPi)
    self.settings = Module(name: "Settings", identifier: .Settings)
    super.init()
  }

  @objc func list() -> Array<Module> {
    return [
      self.batteryModule,
      self.cellularModule,
      self.gpsModule,
      self.motorsModule,
      self.boatModule,
      self.arduinoModule,
      self.raspberryPiModule,
      self.settings,
    ]
  }

}
