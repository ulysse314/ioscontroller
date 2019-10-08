import UIKit

class DomainButtonListView: UIView {

  var stackView: UIStackView = UIStackView()
  var moduleButtons: Array<ModuleSumupView> = [ModuleSumupView]()
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
  
  func addModuleSumupView(moduleSumupView: ModuleSumupView) {
    moduleSumupView.verticalLabel = !self.verticalButtons
    self.moduleButtons.append(moduleSumupView)
    self.stackView.addArrangedSubview(moduleSumupView)
  }

  func updateView() {
    self.stackView.axis = self.verticalButtons ? .vertical : .horizontal
    for moduleSumupView in self.moduleButtons {
      moduleSumupView.verticalLabel = !self.verticalButtons
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
