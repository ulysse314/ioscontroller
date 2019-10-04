//
//  Modules.swift
//  Ulysse
//
//  Copyright © 2019 Ulysse 314 Boat. All rights reserved.
//

import UIKit

class Modules: NSObject {
  
  @objc var batteryModule: Module
  @objc var cellularModule: Module
  @objc var gpsModule: Module
  @objc var motorsModule: Module
  @objc var boatModule: Module
  @objc var arduinoModule: Module
  @objc var raspberryPiModule: Module
  @objc var settings: Module

  override init() {
    self.batteryModule = Module(name: "Battery", identifier: .Battery)
    self.cellularModule = CellularModule(name: "4G Connection", identifier: .Cellular)
    self.gpsModule = Module(name: "GPS", identifier: .GPS)
    self.motorsModule = Module(name: "Motors", identifier: .Motors)
    self.boatModule = Module(name: "Boat", identifier: .Boat)
    self.arduinoModule = Module(name: "Arduino", identifier: .Arduino)
    self.raspberryPiModule = Module(name: "Raspberry PI", identifier: .RaspberryPi)
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
