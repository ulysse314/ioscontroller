import UIKit

@objc protocol DomainButtonListViewControllerDelegate {
  func domainButtonWasSelected(domain: Domain, buttonFrame: CGRect)
  func domainButtonWasUnselected(domain: Domain)
}

class DomainButtonListViewController: UIViewController {

  @objc var delegate: DomainButtonListViewControllerDelegate?
  var domains: Domains
  var domainButtonListView: DomainButtonListView = DomainButtonListView()
  var selectedButton: ModuleSumupView?

  @objc init(domains: Domains) {
    self.domains = domains
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc var verticalButtons: Bool = false {
    didSet {
      self.domainButtonListView.verticalButtons = self.verticalButtons
    }
  }
  
  func imageForModule(moduleIdentifier: DomainIdentifier) -> UIImage? {
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
    for module in self.domains.list() {
      let image = self.imageForModule(moduleIdentifier: module.identifier)
      weak var weakSelf = self
      let myCallback: (_ moduleButton: ModuleButton) ->() =  { (moduleButton) -> Void in
        weakSelf?.wasSelectedButton(moduleButton: moduleButton)
      }
      let moduleSumupView: ModuleSumupView = ModuleSumupView(image: image, callback: myCallback)
      moduleSumupView.tag = index
      self.domainButtonListView.addModuleSumupView(moduleSumupView: moduleSumupView)
      module.addObserver(self, forKeyPath: "errors", options: .new, context: nil)
      index += 1
    }
    self.view = self.domainButtonListView
  }
  
  @objc func unselectCurrentButton() {
    if (self.selectedButton != nil) {
      let index = self.domainButtonListView.moduleButtons.firstIndex(of: self.selectedButton!)!
      self.selectedButton!.moduleButton.isSelected = false
      self.selectedButton = nil
      self.delegate?.domainButtonWasUnselected(domain: self.domains.list()[index])
    }
  }
  
  func wasSelectedButton(moduleButton: ModuleButton) {
    self.selectedButton?.moduleButton.isSelected = false
    if self.selectedButton?.moduleButton != moduleButton {
      moduleButton.isSelected = true
      self.selectedButton = moduleButton.superview as? ModuleSumupView
      let index = self.domainButtonListView.moduleButtons.firstIndex(of: self.selectedButton!)!
      let frame: CGRect = moduleButton.convert(moduleButton.bounds, to: nil)
      self.delegate?.domainButtonWasSelected(domain: self.domains.list()[index], buttonFrame: frame)
    } else {
      self.unselectCurrentButton()
    }
  }
  
  @objc func updateDomainButtonValues() {
    for i in 0...self.domains.list().count - 1 {
      let domain: Domain = self.domains.list()[i]
      let moduleSumupView: ModuleSumupView = self.domainButtonListView.moduleButtons[i]
      moduleSumupView.updateValues(value1: domain.value1(), value2: domain.value2())
      let errorCount = domain.errors.count
      if moduleSumupView.moduleButton.errorCount != errorCount {
        moduleSumupView.moduleButton.errorCount = errorCount
      }
    }
  }

}
