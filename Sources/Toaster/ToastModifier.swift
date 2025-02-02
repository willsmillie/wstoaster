import SwiftUI
import Combine

public enum ToastPosition {
  case top
  case bottom

  var transition: AnyTransition {
    switch self {
    case .top: return .move(edge: .top).combined(with: .opacity)
    case .bottom: return .move(edge: .bottom).combined(with: .opacity)
    }
  }
}

struct MultiToastManager: ViewModifier {
  @ObservedObject var toastService = ToastService.shared
  @State private var workItems: [UUID: DispatchWorkItem] = [:]
  @State private var dragOffsets: [UUID: CGSize] = [:] // Track drag offset for each toast

  func body(content: Content) -> some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .overlay(
        GeometryReader { geometry in
          VStack(alignment: .center, spacing: 8) {
            // Top-positioned toasts
            VStack {
              ForEach(toastService.toasts.filter { $0.position == .top }, id: \.id) { toast in
                ToastItemView(
                  toast: toast,
                  position: .top,
                  offset: dragOffsets[toast.id] ?? .zero,
                  onDismiss: { dismissToast(id: toast.id) },
                  onDragChange: { newOffset in dragOffsets[toast.id] = newOffset },
                  onDragEnd: { finalOffset, predictedEndOffset in
                    handleDragEnd(finalOffset: finalOffset, predictedEndOffset: predictedEndOffset, id: toast.id)
                  }
                )
                .onAppear {
                  showToast(toast)
                }
              }
            }
            .padding(.top, geometry.safeAreaInsets.top + 8) // Add extra padding for safe area

            Spacer()

            // Bottom-positioned toasts
            VStack {
              ForEach(toastService.toasts.filter { $0.position == .bottom }, id: \.id) { toast in
                ToastItemView(
                  toast: toast,
                  position: .bottom,
                  offset: dragOffsets[toast.id] ?? .zero,
                  onDismiss: { dismissToast(id: toast.id) },
                  onDragChange: { newOffset in dragOffsets[toast.id] = newOffset },
                  onDragEnd: { finalOffset, predictedEndOffset in
                    handleDragEnd(finalOffset: finalOffset, predictedEndOffset: predictedEndOffset, id: toast.id)
                  }
                )
                .onAppear {
                  showToast(toast)
                }
              }
            }
            .padding(.bottom, geometry.safeAreaInsets.bottom + 8) // Add extra padding for safe area
          }
          .animation(.spring(response: 0.5, dampingFraction: 0.6), value: toastService.toasts.count)
          .padding(.vertical)
          .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
        }
      )
      .onChange(of: toastService.toasts) { _ in
        toastService.toasts.forEach { toast in
          if toast.duration > 0 || toast.isPersistent {
            showToast(toast)
          }
        }
      }
  }

  private func handleDragEnd(finalOffset: CGSize, predictedEndOffset: CGSize, id: UUID) {
    if abs(predictedEndOffset.height) > 150 || abs(predictedEndOffset.width) > 150 {
      withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
        dragOffsets[id] = predictedEndOffset // Continue with velocity
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Allow time for animation to finish
        dismissToast(id: id)
      }
    } else {
      withAnimation {
        dragOffsets[id] = .zero // Snap back to original position
      }
    }
  }

  private func showToast(_ toast: Toast) {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()

    workItems[toast.id]?.cancel()

    if !toast.isPersistent && toast.duration > 0 {
      let task = DispatchWorkItem { dismissToast(id: toast.id) }
      workItems[toast.id] = task
      DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
    }
  }

  private func dismissToast(id: UUID) {
    withAnimation {
      toastService.toasts.removeAll { $0.id == id }
      dragOffsets[id] = .zero // Clear offset on dismissal
    }
    workItems[id]?.cancel()
    workItems.removeValue(forKey: id)
  }
}


struct ToastItemView: View {
  let toast: Toast
  let position: ToastPosition
  let offset: CGSize
  let onDismiss: () -> Void
  let onDragChange: (CGSize) -> Void
  let onDragEnd: (CGSize, CGSize) -> Void

  var body: some View {
    ToastView(
      type: toast.type,
      title: toast.title,
      message: toast.message,
      onCancelTapped: onDismiss
    )
    .padding(.horizontal, 16)
    .transition(position.transition)
    .offset(offset) // Apply the current drag offset
    .gesture(
      DragGesture()
        .onChanged { value in
          onDragChange(value.translation)
        }
        .onEnded { value in
          let predictedEndOffset = CGSize(
            width: value.predictedEndTranslation.width,
            height: value.predictedEndTranslation.height
          )
          onDragEnd(value.translation, predictedEndOffset)
        }
    )
  }
}

public extension View {
  func multiToastManager() -> some View {
    self.modifier(MultiToastManager())
  }
}

#Preview {
  if #available(iOS 17.0, *) {
    Color.red.edgesIgnoringSafeArea(.all)
      .multiToastManager()
      .onTapGesture {
        let position: ToastPosition = CGFloat.random(in: 0...1) < 0.5 ? .top : .bottom
        ToastService.shared.addToast(type: .success, title: "I did a thing", message: "look at me go wow", position: position)
      }
  }
}
