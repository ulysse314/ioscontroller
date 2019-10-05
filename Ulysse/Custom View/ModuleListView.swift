import UIKit

@objc protocol ModuleListViewDelegate {
  func moduleButtonWasSelected(index: Int, buttonFrame: CGRect)
  func moduleButtonWasUnselected(index: Int)
}

class ModuleListView: UIView {

  var stackView: UIStackView = UIStackView()
  var moduleButtons: Array<ModuleSumupView> = [ModuleSumupView]()
  var selectedButton: ModuleSumupView?
  var focusedButtonIndex: Int?
  @objc weak var delegate: ModuleListViewDelegate?
  @objc var verticalButtons = false {
    didSet {
      self.updateView()
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor(white: 1, alpha: 0.5)
    self.addSubview(self.stackView)
    self.stackView.translatesAutoresizingMaskIntoConstraints = false
    self.stackView.axis = verticalButtons ? .vertical : .horizontal
    self.stackView.spacing = 8
    NSLayoutConstraint.activate([
      self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
      self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
    ])
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func addModuleButton(image: UIImage?, moduleTag: Int) {
    weak var weakSelf = self
    let myCallback: (_ moduleButton: ModuleButton) ->() =  { (moduleButton) -> Void in
      weakSelf?.wasSelectedButton(moduleButton: moduleButton)
    }
    let moduleSumupView: ModuleSumupView = ModuleSumupView(image: image, callback: myCallback)
    moduleSumupView.verticalLabel = !self.verticalButtons
    self.moduleButtons.append(moduleSumupView)
    moduleSumupView.tag = moduleTag
    self.stackView.addArrangedSubview(moduleSumupView)
  }
  
  func updateView() {
    self.stackView.axis = verticalButtons ? .vertical : .horizontal
    for moduleSumupView in self.moduleButtons {
      moduleSumupView.verticalLabel = !self.verticalButtons
    }
  }
  
  func setErrorNumber(_ errorNumber: Int, buttonTag: Int) {
    let button = self.moduleButton(moduleTag: buttonTag)?.moduleButton
    button?.errorNumber = errorNumber
  }

  @objc func focusNextButton() {
    if (self.focusedButtonIndex == nil) {
      self.focusedButtonIndex = 0
    } else {
      if (self.focusedButtonIndex == self.stackView.arrangedSubviews.count) {
        self.focusedButtonIndex = 0
      }
    }
  }

  @objc func unselectCurrentButton() {
    if (self.selectedButton != nil) {
      let index = self.moduleButtons.firstIndex(of: self.selectedButton!)!
      self.selectedButton!.moduleButton.isSelected = false
      self.selectedButton = nil
      self.delegate?.moduleButtonWasUnselected(index: index)
    }
  }

  func wasSelectedButton(moduleButton: ModuleButton) {
    self.selectedButton?.moduleButton.isSelected = false
    if self.selectedButton?.moduleButton != moduleButton {
      moduleButton.isSelected = true
      self.selectedButton = moduleButton.superview as? ModuleSumupView
      let index = self.moduleButtons.firstIndex(of: self.selectedButton!)!
      let frame: CGRect = moduleButton.convert(moduleButton.bounds, to: nil)
      self.delegate?.moduleButtonWasSelected(index: index, buttonFrame: frame)
    } else {
      self.unselectCurrentButton()
    }
  }

  @objc func moduleButton(moduleTag: Int) -> ModuleSumupView? {
    for moduleSumpView in self.moduleButtons {
      if moduleSumpView.tag == moduleTag {
        return moduleSumpView
      }
    }
    return nil
  }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with:event)
    if (view == self.stackView || view == self) {
      return nil
    }
    return view
  }

}
