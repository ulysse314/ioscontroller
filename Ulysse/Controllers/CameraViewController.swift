import UIKit
import WebKit

class CameraViewController: UIViewController, WKNavigationDelegate {
  var webView: WKWebView = WKWebView()
  var cameraURL: URL

  @objc init(cameraURL: URL) {
    self.cameraURL = cameraURL
    super.init(nibName: nil, bundle: nil)
    self.webView.navigationDelegate = self
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    fatalError("init(nibName:bundle:) has not been implemented")
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.webView.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(self.webView)
    self.view.leadingAnchor.constraint(equalTo: self.webView.leadingAnchor).isActive = true
    self.view.trailingAnchor.constraint(equalTo: self.webView.trailingAnchor).isActive = true
    self.view.topAnchor.constraint(equalTo: self.webView.topAnchor).isActive = true
    self.view.bottomAnchor.constraint(equalTo: self.webView.bottomAnchor).isActive = true
    self.webView.load(URLRequest(url: self.cameraURL))
  }

  func reload() {
    let deadlineTime = DispatchTime.now() + .seconds(2)
    DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
      NSLog("Reload url")
      self.webView.load(URLRequest(url: self.cameraURL))
    }
  }

  // MARK: - WKNavigationDelegate

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    NSLog("didFinish")
    self.reload()
  }

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    NSLog("didFail")
    self.reload()
  }

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      NSLog("didStartProvisionalNavigation")
  }

  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    NSLog("didFailProvisionalNavigation")
    self.reload()
  }

  func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    NSLog("didCommit"
  }

 func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    NSLog("decidePolicyFor")
    decisionHandler(.allow)
  }


}
