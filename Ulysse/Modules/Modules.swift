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

  override init() {
    self.batteryModule = Module(name: "Battery")
    self.cellularModule = Module(name: "4G Connection")
    self.gpsModule = Module(name: "GPS")
    self.motorsModule = Module(name: "Motors")
    self.boatModule = Module(name: "Boat")
    self.arduinoModule = Module(name: "Arduino")
    self.raspberryPiModule = Module(name: "Raspberry PI")
    super.init()
  }
}
