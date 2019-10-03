import UIKit

class ViewControllerPresenterViewController: UIViewController {
  var contentView: ModulePresenterView = ModulePresenterView(frame: CGRect.zero)
  @objc var isVertical: Bool = false {
    didSet {
      self.contentView.isVertical = self.isVertical
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
//        controller.view.translatesAutoresizingMaskIntoConstraints = false
//        self.contentView.addSubview(controller.view)
//        NSLayoutConstraint.activate([
//          controller.view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
//          controller.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
//          self.contentView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor),
//          self.contentView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
//        ])
//        self.addChild(controller)
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
