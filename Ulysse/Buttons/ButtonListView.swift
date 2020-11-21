import UIKit

class ButtonListView: UIView {

  var stackView: UIStackView = UIStackView()
  var buttonViewes: Array<ButtonView> = [ButtonView]()
  var focusedButtonIndex: Int?
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
    self.stackView.spacing = 10
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
  
  func addButtonView(buttonView: ButtonView) {
    buttonView.verticalLabel = !self.verticalButtons
    self.buttonViewes.append(buttonView)
    self.stackView.addArrangedSubview(buttonView)
  }

  func updateView() {
    self.stackView.axis = self.verticalButtons ? .vertical : .horizontal
    for buttonView in self.buttonViewes {
      buttonView.verticalLabel = !self.verticalButtons
    }
  }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with:event)
    if (view == self.stackView || view == self) {
      return nil
    }
    return view
  }

}
