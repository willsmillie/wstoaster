import SwiftUI

public struct Toast: Equatable {
  let id = UUID()
  var type: ToastStyle
  var title: String
  var message: String
  var duration: Double
  var offset: CGSize = .zero
  var isPersistent: Bool
  var position: ToastPosition

  public init(type: ToastStyle, title: String, message: String, duration: Double = 3, isPersistent: Bool = false, position: ToastPosition = .top) {
    self.type = type
    self.title = title
    self.message = message
    self.duration = duration
    self.isPersistent = isPersistent
    self.position = position
  }

  mutating func set(offset: CGSize) {
    self.offset = offset
  }
}
