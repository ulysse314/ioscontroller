import Foundation

class SocketConnection : NSObject, StreamDelegate, Connection {
  var delegate: ConnectionDelegate?
  var state: StateConnection
  var server: String?
  var port: Int?
  public private(set) var inputStream: InputStream?
  public private(set) var outputStream: OutputStream?

  override init() {
    self.state = .Closed
    super.init()
  }

  func open(server: String, port: Int) {
    self.server = server
    self.port = port
    self.openInternal()
  }

  func close() {
    self.closeInternal()
  }

  func openInternal() {
    self.state = .Opening
    if (self.server == nil || self.port == nil) {
      return
    }
    Stream.getStreamsToHost(withName: self.server!, port: self.port!, inputStream: &self.inputStream, outputStream: &self.outputStream)
    self.inputStream?.delegate = self
    self.outputStream?.delegate = self
    inputStream?.schedule(in: .current, forMode: RunLoop.Mode.default);
    outputStream?.schedule(in: .current, forMode: RunLoop.Mode.default);
    inputStream?.open()
    outputStream?.open()
  }

  func closeInternal() {
    inputStream?.close()
    outputStream?.close()
    inputStream?.remove(from: .current, forMode: RunLoop.Mode.default)
    outputStream?.remove(from: .current, forMode: RunLoop.Mode.default)
    inputStream?.delegate = nil
    outputStream?.delegate = nil
    self.state = .Closed
  }

  // MARK: - Stream Delegate

  func stream(_ stream: Stream, handle eventCode: Stream.Event) {
    if eventCode.contains(Stream.Event.errorOccurred) {
      self.closeInternal()
      return;
    }
    if eventCode.contains(Stream.Event.endEncountered) {
      self.closeInternal()
      return;
    }
    if stream == self.inputStream {
      self.inputStreamHandleEvent(eventCode)
    } else if stream == self.outputStream {
      self.outputStreamHandleEvent(eventCode)
    }
  }

  // MARK: - Private

  func inputStreamHandleEvent(_ eventCode: Stream.Event) {
    if eventCode.contains(.openCompleted) && (self.outputStream?.hasSpaceAvailable ?? false) && self.state == .Opening {
      self.streamsOpened()
    } else if eventCode.contains(.hasBytesAvailable) {
      self.delegate?.inputConnectionAvailable(self)
    }
  }

  func outputStreamHandleEvent(_ eventCode: Stream.Event) {
    if eventCode.contains(.hasSpaceAvailable) && self.inputStream?.streamStatus == Stream.Status.open && self.state == .Opening {
      self.streamsOpened()
    } else if eventCode.contains(.hasSpaceAvailable) {
      self.delegate?.outputConnectionReady(self)
    }
  }

  func streamsOpened() {
    self.state = .Opened
    self.delegate?.outputConnectionReady(self)
    if self.inputStream?.hasBytesAvailable ?? false {
      self.delegate?.inputConnectionAvailable(self)
    }
  }

  // MARK: - ConnectionDelegate

  var hasBytesAvailable: Bool {
    get {
      return self.inputStream?.hasBytesAvailable ?? false
    }
  }

  func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
    return self.inputStream?.read(buffer, maxLength: len) ?? 0
  }

  // MARK: - OutputConnect

  var hasSpaceAvailable: Bool {
    get {
      return self.outputStream?.hasSpaceAvailable ?? false
    }
  }

  func write(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) -> Int {
    return self.outputStream?.write(buffer, maxLength: len) ?? 0
  }
}
