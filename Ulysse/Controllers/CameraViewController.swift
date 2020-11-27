import UIKit
import WebKit

@objc protocol CameraViewControllerDelegate {

  func cameraViewControllerWasTapped(_ cameraViewController: CameraViewController)

}

class CameraViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

  let ConnectionLostMessageName: String = "connectionLost"
  let ImageClickMessageName: String = "imageClick"

  let webView: WKWebView
  let cameraURL: URL
  @objc var delegate: CameraViewControllerDelegate?

  @objc init(cameraURL: URL) {
    self.cameraURL = cameraURL
    let configuration = WKWebViewConfiguration()
    self.webView = WKWebView(frame: CGRect.zero, configuration: configuration)
    super.init(nibName: nil, bundle: nil)
    self.webView.navigationDelegate = self
    configuration.userContentController.add(self, name: self.ConnectionLostMessageName)
    configuration.userContentController.add(self, name: self.ImageClickMessageName)
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
    self.loadHTML()
  }

  // MARK: - Private

  func html() -> String {
    let html: String = """
<html>
  <body style='margin: 0px; background-color: #333'>
    <img id='image' src='\(self.cameraURL.absoluteString)' style="width: 100%; height:100%; object-fit: contain;"/>
  </body>
<script type="text/javascript">
window.onload = function() {
  window.webkit.messageHandlers.\(self.ConnectionLostMessageName).postMessage({});
};
image = document.getElementById("image");
image.onclick = function() {
  window.webkit.messageHandlers.\(self.ImageClickMessageName).postMessage({});
};
</script>
</html>
"""
    return html
  }

  func loadHTML() {
    self.webView.loadHTMLString(self.html(), baseURL: nil)
  }

  func reloadHTML() {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
      self.loadHTML()
    }
  }

  // MARK: - WKScriptMessageHandler

  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if (message.name == self.ConnectionLostMessageName) {
      self.reloadHTML()
    } else if (message.name == self.ImageClickMessageName) {
      self.delegate?.cameraViewControllerWasTapped(self)
    }
  }

  // MARK: - WKNavigationDelegate

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
  }

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    self.reloadHTML()
  }

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      NSLog("didStartProvisionalNavigation")
  }

  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    self.reloadHTML()
  }

  func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
  }

 func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    decisionHandler(.allow)
  }


}
