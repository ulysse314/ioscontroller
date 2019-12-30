import Foundation

class Domains: NSObject {
  
  @objc var batteryDomain: BatteryDomain
  @objc var cellularDomain: CellularDomain
  @objc var gpsDomain: GPSDomain
  @objc var motorsDomain: MotorDomain
  @objc var hullDomain: ModuleDomain
  @objc var arduinoDomain: ModuleDomain
  @objc var raspberryPiDomain: RaspberryPiDomain
  @objc var settingsDomain: Domain

  override init() {
    self.batteryDomain = BatteryDomain(identifier: .Battery)
    self.cellularDomain = CellularDomain(identifier: .Cellular)
    self.gpsDomain = GPSDomain(identifier: .GPS)
    self.motorsDomain = MotorDomain(identifier: .Motors)
    self.hullDomain = HullDomain(identifier: .Boat)
    self.arduinoDomain = ModuleDomain(name: "Arduino", identifier: .Arduino)
    self.raspberryPiDomain = RaspberryPiDomain(identifier: .RaspberryPi)
    self.settingsDomain = Domain(name: "Settings", identifier: .Settings)
    super.init()
  }

  @objc func list() -> Array<Domain> {
    return [
      self.batteryDomain,
      self.cellularDomain,
      self.gpsDomain,
      self.motorsDomain,
      self.hullDomain,
      self.arduinoDomain,
      self.raspberryPiDomain,
      self.settingsDomain,
    ]
  }

}
