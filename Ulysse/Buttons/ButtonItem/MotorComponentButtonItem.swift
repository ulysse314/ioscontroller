import UIKit

class MotorComponentButtonItem: BoatComponentButtonItem {
  
  @objc init(boatComponents: Array<BoatComponent>) {
    super.init(boatComponents: boatComponents, name: "Motors", identifier: .Motors, image: UIImage.init(named: "motor"))
  }

  // MARK: - Short values

  override func value1() -> String? {
    let boatComponent: BoatComponent? = self.boatComponent(identifier: .LeftMotor)
    let leftTemp: Int = Int(getDouble(value: boatComponent?.value(key: "t")))
    return "\(leftTemp)ºC"
  }
  
  override func value2() -> String? {
    let boatComponent: BoatComponent? = self.boatComponent(identifier: .RightMotor)
    let rightTemp: Int = Int(getDouble(value: boatComponent?.value(key: "t")))
    return "\(rightTemp)ºC"
  }

}
