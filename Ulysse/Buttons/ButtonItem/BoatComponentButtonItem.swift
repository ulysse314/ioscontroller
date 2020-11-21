import UIKit

class BoatComponentButtonItem: ButtonItem {

  class var ValuesUpdated: String {
    return "ValuesUpdated"
  }
  private var boatComponentAdded = false
  @objc private(set) var boatComponents: Array<BoatComponent> = [BoatComponent]()
  private(set) var boatComponentKeys: Dictionary<String, Array<String>> = [String : Array<String>]()

  @objc init(boatComponents: Array<BoatComponent>, name: String, identifier: ButtonItemIdentifier, image: UIImage?) {
    self.boatComponents = boatComponents
    super.init(name: name, identifier: identifier, image: image)
  }

  // MARK: - BoatComponents

  @objc func boatComponent(identifier: BoatComponent.BoatComponentIdentifier) -> BoatComponent? {
    for boatComponent in self.boatComponents {
      if boatComponent.identifier == identifier {
        return boatComponent
      }
    }
    return nil
  }

  override func errorCount() -> Int {
    var result: Int = 0
    for boatComponent in self.boatComponents {
      result += boatComponent.errors.count
    }
    return result
  }

}
