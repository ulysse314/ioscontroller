import UIKit

@objc protocol ModuleListViewControllerDelegate {
  func moduleButtonWasSelected(module: Module, buttonFrame: CGRect)
  func moduleButtonWasUnselected(module: Module)
}

class ModuleListViewController: UIViewController {

  @objc var delegate: ModuleListViewControllerDelegate?
  var modules: Modules
  var moduleListView: ModuleListView = ModuleListView()
  var selectedButton: ModuleSumupView?

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
    var index: Int = 0
    for module in self.modules.list() {
      let image = self.imageForModule(moduleIdentifier: module.identifier)
      weak var weakSelf = self
      let myCallback: (_ moduleButton: ModuleButton) ->() =  { (moduleButton) -> Void in
        weakSelf?.wasSelectedButton(moduleButton: moduleButton)
      }
      let moduleSumupView: ModuleSumupView = ModuleSumupView(image: image, callback: myCallback)
      moduleSumupView.tag = index
      self.moduleListView.addModuleSumupView(moduleSumupView: moduleSumupView)
      module.addObserver(self, forKeyPath: "errors", options: .new, context: nil)
      index += 1
    }
    self.view = self.moduleListView
  }
  
  @objc func unselectCurrentButton() {
    if (self.selectedButton != nil) {
      let index = self.moduleListView.moduleButtons.firstIndex(of: self.selectedButton!)!
      self.selectedButton!.moduleButton.isSelected = false
      self.selectedButton = nil
      self.delegate?.moduleButtonWasUnselected(module: self.modules.list()[index])
    }
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let module: Module = object as? Module {
      let index = self.modules.list().firstIndex(of: module)!
      let moduleButton = self.moduleListView.moduleButtons[index]
      let errorCount = module.errors?.count ?? 0
      if moduleButton.moduleButton.errorNumber != errorCount {
        moduleButton.moduleButton.errorNumber = errorCount
      }
    }
  }
  
  func wasSelectedButton(moduleButton: ModuleButton) {
    self.selectedButton?.moduleButton.isSelected = false
    if self.selectedButton?.moduleButton != moduleButton {
      moduleButton.isSelected = true
      self.selectedButton = moduleButton.superview as? ModuleSumupView
      let index = self.moduleListView.moduleButtons.firstIndex(of: self.selectedButton!)!
      let frame: CGRect = moduleButton.convert(moduleButton.bounds, to: nil)
      self.delegate?.moduleButtonWasSelected(module: self.modules.list()[index], buttonFrame: frame)
    } else {
      self.unselectCurrentButton()
    }
  }

}
