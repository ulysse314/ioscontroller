import UIKit

class ViewControllerPresenterViewController: UIViewController {
  var contentView: ModulePresenterView = ModulePresenterView(frame: CGRect.zero)
  @objc var verticalButtons: Bool = false {
    didSet {
      self.contentView.verticalButtons = self.verticalButtons
    }
  }

  @objc var viewController: UIViewController? {
    willSet {
      if (self.viewController != nil) {
        self.viewController!.view.removeFromSuperview()
        self.viewController?.removeFromParent()
      }
    }
    didSet {
      if (self.viewController != nil) {
        let controller: UIViewController = self.viewController!
        self.contentView.contentView = controller.view
      }
    }
  }
  
  override func loadView() {
    self.view = self.contentView
    self.view.layer.backgroundColor = UIColor.clear.cgColor
    self.view.isOpaque = false
  }
  
  @objc func openViewController(position: CGFloat) {
    self.contentView.position = position
    self.contentView.setNeedsDisplay()
  }
}
