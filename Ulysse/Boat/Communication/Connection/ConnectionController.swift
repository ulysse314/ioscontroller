import Foundation

@objc protocol ConnectionControllerDelegate {
  func inputAvailable(connectionController: ConnectionController)
  func outputReady(connectionController: ConnectionController)
}

class ConnectionController : NSObject, ConnectionDelegate {

  @objc enum ConnectionControllerState : Int {
    case Stopped
    case Connecting
    case Handshake
    case Opened
  }

  @objc var hasBytesAvailable: Bool {
    get {
      return self.socketConnection.hasBytesAvailable
    }
  }
  @objc var hasSpaceAvailable: Bool {
    get {
      return self.socketConnection.hasSpaceAvailable
    }
  }
  @objc dynamic public private(set) var state: ConnectionControllerState
  @objc var delegate: ConnectionControllerDelegate?
  @objc public var outputStream: OutputStream? {
    get {
      return self.socketConnection.outputStream
    }
  }

  private var config: Config
  private var socketConnection: SocketConnection
  private let reconnectDelayInSeconds: Double = 5

  @objc init(config: Config) {
    self.state = .Stopped
    self.config = config
    self.socketConnection = SocketConnection.init()
    self.state = .Stopped
    super.init()
    self.socketConnection.delegate = self
    self.config.addObserver(self, forKeyPath: "boatName", options: .new, context: nil)
  }

  deinit {
    self.config.removeObserver(self, forKeyPath: "boatName")
  }

  @objc func start() {
    self.state = .Connecting
    let server: String? = self.config.value(forKey: "value_relay_server") as? String;
    let port: Int? = (self.config.value(forKey:"controller_port") as? NSNumber ?? nil)?.intValue;
    if (server == nil || port == nil) {
      return
    }
    self.socketConnection.open(server: server!, port: port!)
    DispatchQueue.main.asyncAfter(deadline: .now() + reconnectDelayInSeconds) {
      self.checkIfConnected()
    }
  }

  @objc func stop() {
    self.internalStop()
    self.state = .Stopped
  }

  @objc func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
    return self.socketConnection.read(buffer, maxLength: len)
  }

  @objc func write(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) -> Int {
    return self.socketConnection.write(buffer, maxLength: len)
  }

  @objc override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "boatName" {
      if self.state != .Stopped {
        self.internalStop()
        self.start()
      }
    }
  }

  // MARK: - ConnectionDelegate

  func inputConnectionAvailable(_ connection: Connection) {
    switch self.state {
    case .Connecting:
      break
    case .Handshake:
      break
    case .Opened:
      self.delegate?.inputAvailable(connectionController: self)
      break
    case .Stopped:
      break
    }
  }

  func outputConnectionReady(_ connection: Connection) {
    switch self.state {
    case .Connecting:
      self.state = .Handshake
      var token: String? = self.config.value(forKey: "controller_key") as? String;
      if token == nil {
        self.state = .Stopped
        return
      }
      token?.append("\n")
      let data: Data? = token!.data(using: .utf8)
      if data == nil {
        self.state = .Stopped
        return
      }
      let bytes = [UInt8](data!)
      if self.socketConnection.write(bytes, maxLength: data!.count) != data!.count {
        self.state = .Stopped
        return
      }
      self.state = .Opened
      break
    case .Handshake:
      break
    case .Opened:
      self.delegate?.outputReady(connectionController: self)
      break
    case .Stopped:
      break
    }
  }

  // MARK: - Private

  func internalStop() {
    self.socketConnection.close()
  }

  func checkIfConnected() {
    if self.state == .Connecting {
      self.internalStop()
      self.start()
    }
  }

}
