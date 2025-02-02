import SwiftUI

@MainActor
public class ToastService: ObservableObject {
  public static let shared = ToastService()
  @Published var toasts: [Toast] = []

  public init() {}

  public func addToast(type: ToastStyle, title: String, message: String = "", duration: TimeInterval = 3, position: ToastPosition = .top) {
    let newToast = Toast(type: type, title: title, message: message, duration: duration, position: position)
    DispatchQueue.main.async {
      self.toasts.append(newToast)
    }
  }

  public func addToast(_ newToast: Toast) {
    DispatchQueue.main.async {
      self.toasts.append(newToast)
    }
  }
}

