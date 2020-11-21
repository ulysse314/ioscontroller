import UIKit

@objc protocol ButtonListViewControllerDelegate {
  func buttonWasSelected(item: ButtonItem, buttonFrame: CGRect)
  func buttonWasUnselected(item: ButtonItem)
}

class ButtonListViewController: UIViewController {

  @objc var delegate: ButtonListViewControllerDelegate?
  let buttonItems: Array<ButtonItem>
  let buttonListView: ButtonListView
  var selectedButton: ButtonView?

  @objc init(buttonItems: Array<ButtonItem>) {
    self.buttonItems = buttonItems
    self.buttonListView = ButtonListView()
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc var verticalButtons: Bool = false {
    didSet {
      self.buttonListView.verticalButtons = self.verticalButtons
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    var index: Int = 0
    for buttonItem in self.buttonItems {
      let image = buttonItem.image
      weak var weakSelf = self
      let myCallback: (_ buttonImageView: ButtonImageView) ->() =  { (buttonImageView) -> Void in
        weakSelf?.wasSelectedButton(buttonImageView: buttonImageView)
      }
      let buttonView: ButtonView = ButtonView(image: image, callback: myCallback)
      buttonView.tag = index
      self.buttonListView.addButtonView(buttonView: buttonView)
      buttonItem.addObserver(self, forKeyPath: "errors", options: .new, context: nil)
      index += 1
    }
    self.view = self.buttonListView
  }
  
  @objc func unselectCurrentButton() {
    if (self.selectedButton != nil) {
      let index = self.buttonListView.buttonViewes.firstIndex(of: self.selectedButton!)!
      self.selectedButton!.buttonImageView.isSelected = false
      self.selectedButton = nil
      self.delegate?.buttonWasUnselected(item: self.buttonItems[index])
    }
  }
  
  func wasSelectedButton(buttonImageView: ButtonImageView) {
    self.selectedButton?.buttonImageView.isSelected = false
    if self.selectedButton?.buttonImageView != buttonImageView {
      buttonImageView.isSelected = true
      self.selectedButton = buttonImageView.superview as? ButtonView
      let index = self.buttonListView.buttonViewes.firstIndex(of: self.selectedButton!)!
      let frame: CGRect = buttonImageView.convert(buttonImageView.bounds, to: nil)
      self.delegate?.buttonWasSelected(item: self.buttonItems[index], buttonFrame: frame)
    } else {
      self.unselectCurrentButton()
    }
  }
  
  @objc func updateButtonValues() {
    for i in 0...self.buttonItems.count - 1 {
      let buttonItem: ButtonItem = self.buttonItems[i]
      let buttonView: ButtonView = self.buttonListView.buttonViewes[i]
      buttonView.updateValues(value1: buttonItem.value1(), value2: buttonItem.value2())
      let errorCount = buttonItem.errorCount()
      if buttonView.buttonImageView.errorCount != errorCount {
        buttonView.buttonImageView.errorCount = errorCount
      }
    }
  }

}
