import Foundation

enum StateConnection: Int {
  case Closed
  case Opening
  case Opened
}

protocol Connection {
  var state: StateConnection { get }
  var delegate: ConnectionDelegate? { get set }
  var hasBytesAvailable: Bool { get }
  var hasSpaceAvailable: Bool { get }

  func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int
  func write(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) -> Int
}

protocol ConnectionDelegate {
  func inputConnectionAvailable(_ connection: Connection)
  func outputConnectionReady(_ connection: Connection)
}
