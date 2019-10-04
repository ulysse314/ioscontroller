import UIKit

@objc protocol ModuleListViewDelegate {
  func moduleButtonWasSelected(button: ModuleButton)
  func moduleButtonWasUnselected(button: ModuleButton)
}

class ModuleListView: UIView {

  var stackView: UIStackView = UIStackView()
  var moduleButtons: Array<ModuleButton> = [ModuleButton]()
  var selectedButton: ModuleButton?
  var focusedButtonIndex: Int?
  @objc weak var delegate: ModuleListViewDelegate?
  @objc var verticalButtons = false {
    didSet {
      self.stackView.axis = verticalButtons ? .vertical : .horizontal
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
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

  @objc func addModuleButton(image: UIImage?, buttonTag: Int) {
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
      if (self.focusedButtonIndex == self.stackView.arrangedSubviews.count) {
        self.focusedButtonIndex = 0
      }
    }
  }

  @objc func unselectCurrentButton() {
    if (self.selectedButton != nil) {
      let selectedButton = self.selectedButton!
      self.selectedButton!.isSelected = false
      self.selectedButton = nil
      self.delegate?.moduleButtonWasUnselected(button: selectedButton)
    }
  }

  func wasSelectedButton(button: ModuleButton) {
    self.selectedButton?.isSelected = false
    if self.selectedButton != button {
      button.isSelected = true
      self.selectedButton = button
      self.delegate?.moduleButtonWasSelected(button: button)
    } else {
      self.unselectCurrentButton()
    }
  }

  @objc func moduleButton(buttonTag: Int) -> ModuleButton? {
    for button in self.moduleButtons {
      if button.tag == buttonTag {
        return button
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
