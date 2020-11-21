import Foundation

class Boat : NSObject {

  @objc let batteryBoatComponent: BatteryBoatComponent
  @objc let cellularBoatComponent: CellularBoatComponent
  @objc let gpsBoatComponent: GPSBoatComponent
  @objc let leftMotorBoatComponent: MotorBoatComponent
  @objc let rightMotorBoatComponent: MotorBoatComponent
  @objc let hullBoatComponent: HullBoatComponent
  @objc let arduinoBoatComponent: BoatComponent
  @objc let raspberryPiBoatComponent: RaspberryPiBoatComponent
  @objc var errors: Array<BoatComponentError> = [BoatComponentError]()

  override init() {
    self.batteryBoatComponent = BatteryBoatComponent()
    self.cellularBoatComponent = CellularBoatComponent()
    self.gpsBoatComponent = GPSBoatComponent()
    self.leftMotorBoatComponent = MotorBoatComponent(name: "Left", identifier: .LeftMotor)
    self.rightMotorBoatComponent = MotorBoatComponent(name: "Right", identifier: .RightMotor)
    self.hullBoatComponent = HullBoatComponent()
    self.arduinoBoatComponent = ArduinoBoatComponent()
    self.raspberryPiBoatComponent = RaspberryPiBoatComponent()
    super.init()
  }

  @objc func list() -> Array<BoatComponent> {
    return [
      self.batteryBoatComponent,
      self.cellularBoatComponent,
      self.gpsBoatComponent,
      self.leftMotorBoatComponent,
      self.rightMotorBoatComponent,
      self.hullBoatComponent,
      self.arduinoBoatComponent,
      self.raspberryPiBoatComponent,
    ]
  }

  class var UpdatedValueNotificationName: String {
    return "ValuesUpdated"
  }

  @objc private(set) var boatComponents: Array<BoatComponent> = [BoatComponent]()
  private(set) var boatComponentKeys: Dictionary<String, Array<String>> = [String : Array<String>]()
  
  @objc func valueUpdateStart() {
    self.errors = [BoatComponentError]()
  }

  @objc func valueUpdateDone() {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Boat.UpdatedValueNotificationName), object:self)
  }

  // MARK: - BoatComponents

  @objc func boatComponent(name: String) -> BoatComponent? {
    for boatComponent in self.boatComponents {
      if boatComponent.name == name {
        return boatComponent
      }
    }
    return nil
  }

}
