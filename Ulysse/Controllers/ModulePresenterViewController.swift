import UIKit

class ViewControllerPresenterViewController: UIViewController {
  var contentView: ModulePresenterView

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

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.contentView = ModulePresenterView(frame: CGRect.zero)
    self.contentView.translatesAutoresizingMaskIntoConstraints = false
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.layer.backgroundColor = UIColor.clear.cgColor
    self.view.isUserInteractionEnabled = false
    self.view.addSubview(self.contentView)
    NSLayoutConstraint.activate([
      self.contentView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      ])
    self.view.isOpaque = false
  }
  
  @objc func openViewController(vPosition: CGFloat) {
    self.contentView.vPosition = vPosition
    self.contentView.setNeedsDisplay()
  }
}
