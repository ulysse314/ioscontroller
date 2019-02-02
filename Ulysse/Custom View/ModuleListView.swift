import UIKit

@objc protocol ModuleListViewDelegate {
  func moduleButtonWasSelected(button: ModuleButton)
  func moduleButtonWasUnselected(button: ModuleButton)
}

class ModuleListView: UIView {

  var stackView: UIStackView
  var moduleButtons: Array<ModuleButton>
  var selectedButton: ModuleButton?
  var focusedButtonIndex: Int?
  @objc weak var delegate: ModuleListViewDelegate?

  override init(frame: CGRect) {
    self.moduleButtons = [ModuleButton]()
    self.stackView = UIStackView(frame: frame)
    super.init(frame: frame)
    self.addSubview(self.stackView)
    self.stackView.translatesAutoresizingMaskIntoConstraints = false
    self.stackView.axis = .vertical
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

  @objc func addModuleButton(image: UIImage, buttonTag: Int) {
    weak var weakSelf = self
    let myCallback: (_ button: ModuleButton) ->() =  { (button) -> Void in
      weakSelf?.wasSelectedButton(button: button)
    }
    let button: ModuleButton = ModuleButton(image: image, callback: myCallback)
    self.moduleButtons.append(button)
    button.tag = buttonTag
    self.stackView.addArrangedSubview(button)
  }
  
  @objc func setErrorNumber(_ errorNumber: Int, buttonTag: Int) {
    let button = self.moduleButton(buttonTag: buttonTag)
    button?.errorNumber = errorNumber
  }

  @objc func focusNextButton() {
    if (self.focusedButtonIndex == nil) {
      self.focusedButtonIndex = 0
    } else {
//      let previousFocusedButton: ModuleButton = self.stackView.arrangedSubviews[0] as! ModuleButton
//      previousFocusedButton.state = .normal
//      self.focusedButtonIndex += 1
      if (self.focusedButtonIndex == self.stackView.arrangedSubviews.count) {
        self.focusedButtonIndex = 0
      }
    }
//    let focusedButton: ModuleButton = self.stackView.arrangedSubviews[0] as! ModuleButton
  }

  func wasSelectedButton(button: ModuleButton) {
    self.selectedButton?.isSelected = false
    if self.selectedButton != button {
      button.isSelected = true
      self.selectedButton = button
      self.delegate?.moduleButtonWasSelected(button: button)
    } else {
      button.isSelected = false
      self.selectedButton = nil
      self.delegate?.moduleButtonWasUnselected(button: button)
    }
  }

  func moduleButton(buttonTag: Int) -> ModuleButton? {
    for button in self.moduleButtons {
      if button.tag == buttonTag {
        return button
      }
    }
    return nil
  }

}
