import UIKit

class MainViewLayoutController: NSObject {
  @objc enum FullScreenView: Int {
    case mapView
    case cameraView
  }

  @objc var fullScreenView: FullScreenView = .mapView {
    didSet {
    }
  }
  var mainView: UIView
  @objc var mapView: UIView! {
    didSet {
      self.mapView.translatesAutoresizingMaskIntoConstraints = false
      self.mainView.insertSubview(self.mapView, at: 0)
    }
  }
  @objc var statusView: UIView! {
    didSet {
      self.statusView.translatesAutoresizingMaskIntoConstraints = false
      self.mainView.addSubview(self.statusView!)
    }
  }
  @objc var domainButtonListView: UIView! {
    didSet {
      self.domainButtonListView.translatesAutoresizingMaskIntoConstraints = false
      self.mainView.addSubview(self.domainButtonListView)
    }
  }
  @objc var currentConsumptionProgressView: UIView! {
    didSet {
      self.currentConsumptionProgressView.translatesAutoresizingMaskIntoConstraints = false
      self.mainView.addSubview(self.currentConsumptionProgressView)
    }
  }
  @objc var cameraView: UIView? {
    willSet {
      if self.cameraView != nil {
        self.cameraView?.removeFromSuperview()
        self.cameraViewCenterConstraints = []
        self.cameraViewSizeConstraints = []
        self.fullScreenView = .mapView
      }
    }
    didSet {
      if self.cameraView != nil {
        self.cameraView!.translatesAutoresizingMaskIntoConstraints = false
        self.mainView.insertSubview(self.cameraView!, aboveSubview: self.mapView)
        self.layout(miniView: self.cameraView!, centerConstraints: &self.cameraViewCenterConstraints)
        self.layout(miniView: self.cameraView!, sizeConstraints: &self.cameraViewSizeConstraints)
      } else {
        self.switchToMap()
      }
    }
  }

  var cameraViewCenterConstraints: Array<NSLayoutConstraint> = []
  var cameraViewSizeConstraints: Array<NSLayoutConstraint> = []
  var mapViewViewCenterConstraints: Array<NSLayoutConstraint> = []
  var mapViewViewSizeConstraints: Array<NSLayoutConstraint> = []

  @objc required init(mainView: UIView) {
    self.mainView = mainView
  }

  @objc func setupLayouts() {
    self.layout(bigView: self.mapView, sizeConstraints: &self.mapViewViewSizeConstraints)
    self.layout(bigView: self.mapView, centerConstraints: &self.mapViewViewCenterConstraints)
    NSLayoutConstraint.activate([
      self.domainButtonListView.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor, constant: 10),
      self.mainView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.domainButtonListView.bottomAnchor, constant: 10),
      self.mainView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.statusView.trailingAnchor, constant: 10),
      self.statusView.topAnchor.constraint(equalTo: self.mainView.topAnchor, constant: 10),
      self.statusView.heightAnchor.constraint(equalToConstant: 24),
      self.mainView.leadingAnchor.constraint(equalTo: self.currentConsumptionProgressView.leadingAnchor, constant: -8),
      self.mainView.trailingAnchor.constraint(equalTo: self.currentConsumptionProgressView.trailingAnchor, constant: 8),
      self.mainView.bottomAnchor.constraint(equalTo: self.currentConsumptionProgressView.bottomAnchor, constant: 4),
    ])
  }

  @objc func swithcMainView() {
    if self.fullScreenView == .cameraView {
      self.switchToMap();
    } else {
      self.switchToCamera();
    }
  }

  @objc func switchToCamera() {
    if self.cameraView == nil || self.fullScreenView == .cameraView {
      return
    }
    self.fullScreenView = .cameraView
    UIView .animate(withDuration: 0.25) {
      self.mainView.sendSubviewToBack(self.cameraView!)
      self.layout(miniView: self.mapView, sizeConstraints: &self.mapViewViewSizeConstraints)
      self.layout(miniView: self.mapView, centerConstraints: &self.mapViewViewCenterConstraints)
      self.layout(bigView: self.cameraView!, sizeConstraints: &self.cameraViewSizeConstraints)
      self.layout(bigView: self.cameraView!, centerConstraints: &self.cameraViewCenterConstraints)
      self.mainView.layoutIfNeeded()
    }
  }

  @objc func switchToMap() {
    if self.fullScreenView == .mapView {
      return
    }
    self.fullScreenView = .mapView
    UIView .animate(withDuration: 0.25) {
      if self.cameraView != nil {
        self.layout(miniView: self.cameraView!, sizeConstraints: &self.cameraViewSizeConstraints)
        self.layout(miniView: self.cameraView!, centerConstraints: &self.cameraViewCenterConstraints)
      }
      self.mainView.sendSubviewToBack(self.mapView)
      self.layout(bigView: self.mapView, sizeConstraints: &self.mapViewViewSizeConstraints)
      self.layout(bigView: self.mapView, centerConstraints: &self.mapViewViewCenterConstraints)
      self.mainView.layoutIfNeeded()
    }
  }

  func layout(miniView: UIView, sizeConstraints: inout Array<NSLayoutConstraint>) {
    NSLayoutConstraint.deactivate(sizeConstraints)
    sizeConstraints.removeAll()
    sizeConstraints.append(contentsOf: [
      miniView.widthAnchor.constraint(equalToConstant: 200),
      miniView.heightAnchor.constraint(equalToConstant: 200 / 4 * 3),
    ])
    NSLayoutConstraint.activate(sizeConstraints)
  }

  func layout(miniView: UIView, centerConstraints: inout Array<NSLayoutConstraint>) {
    NSLayoutConstraint.deactivate(centerConstraints)
    centerConstraints.removeAll()
    centerConstraints.append(contentsOf: [
      self.mainView.bottomAnchor.constraint(equalTo: miniView.bottomAnchor, constant: 8),
      self.mainView.trailingAnchor.constraint(equalTo: miniView.trailingAnchor, constant: 8),
    ])
    NSLayoutConstraint.activate(centerConstraints)
  }

  func layout(bigView: UIView, sizeConstraints: inout Array<NSLayoutConstraint>) {
    NSLayoutConstraint.deactivate(sizeConstraints)
    sizeConstraints.removeAll()
    sizeConstraints.append(contentsOf: [
      bigView.widthAnchor.constraint(equalTo: self.mainView.widthAnchor),
      bigView.heightAnchor.constraint(equalTo: self.mainView.heightAnchor),
    ])
    NSLayoutConstraint.activate(sizeConstraints)
  }

  func layout(bigView: UIView, centerConstraints: inout Array<NSLayoutConstraint>) {
    NSLayoutConstraint.deactivate(centerConstraints)
    centerConstraints.removeAll()
    centerConstraints.append(contentsOf: [
      self.mainView.centerXAnchor.constraint(equalTo: bigView.centerXAnchor),
      self.mainView.centerYAnchor.constraint(equalTo: bigView.centerYAnchor),
    ])
    NSLayoutConstraint.activate(centerConstraints)
  }
}
