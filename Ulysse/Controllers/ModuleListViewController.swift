import UIKit

@objc protocol ModuleListViewControllerDelegate {
  func moduleButtonWasSelected(module: Module, position: CGFloat)
  func moduleButtonWasUnselected(module: Module)
}

class ModuleListViewController: UIViewController, ModuleListViewDelegate {

  @objc var delegate: ModuleListViewControllerDelegate?
  var modules: Modules
  var moduleListView: ModuleListView = ModuleListView()

  @objc init(modules: Modules) {
    self.modules = modules
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc var verticalButtons: Bool = false {
    didSet {
      self.moduleListView.verticalButtons = self.verticalButtons
    }
  }
  
  func imageForModule(moduleIdentifier: ModuleIdentifier) -> UIImage? {
    switch moduleIdentifier {
    case .Battery:
      return UIImage.init(named: "battery")
    case .Cellular:
      return UIImage.init(named: "cellular")
    case .GPS:
      return UIImage.init(named: "satellite")
    case .Motors:
      return UIImage.init(named: "motor")
    case .Boat:
      return UIImage.init(named: "boat")
    case .Arduino:
      return UIImage.init(named: "arduino")
    case .RaspberryPi:
      return UIImage.init(named: "raspberrypi")
    case .Settings:
      return UIImage.init(named: "settings")
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.moduleListView.delegate = self
    var index: Int = 0
    for module in self.modules.list() {
      let image = self.imageForModule(moduleIdentifier: module.identifier)
      self.moduleListView.addModuleButton(image: image, buttonTag: index)
      module.addObserver(self, forKeyPath: "errors", options: .new, context: nil)
      index += 1
    }
    self.view = self.moduleListView
  }
  
  @objc func unselectCurrentButton() {
    self.moduleListView.unselectCurrentButton()
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let module: Module = object as? Module {
      let index = self.modules.list().firstIndex(of: module)!
      let moduleButton = self.moduleListView.moduleButtons[index]
      let errorCount = module.errors?.count ?? 0
      if moduleButton.errorNumber != errorCount {
        moduleButton.errorNumber = errorCount
      }
    }
  }
  
  func moduleButtonWasSelected(button: ModuleButton) {
    let index: Int! = self.moduleListView.moduleButtons.firstIndex(of: button)
    let module = self.modules.list()[index]
    self.delegate?.moduleButtonWasUnselected(module: module)
    let x: CGFloat = button.bounds.origin.x + button.bounds.size.width / 2
    let y: CGFloat = button.bounds.origin.y + button.bounds.size.height / 2
    var point: CGPoint = CGPoint(x: x, y: y)
    point = button.convert(point, to: nil)
    var position: CGFloat = 0
    if self.verticalButtons {
      position = point.y
    } else {
      position = point.x
    }
    self.delegate?.moduleButtonWasSelected(module: module, position: position)
  }
  
  func moduleButtonWasUnselected(button: ModuleButton) {
    let index: Int! = self.moduleListView.moduleButtons.firstIndex(of: button)
    let module = self.modules.list()[index]
    self.delegate?.moduleButtonWasUnselected(module: module)
  }

}
