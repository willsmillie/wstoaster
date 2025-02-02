import SwiftUI

public struct DismissableToastView: View {
  var type: ToastStyle
  var title: String
  var message: String
  var onDismiss: () -> Void
  @State private var offset: CGSize = .zero

  public var body: some View {
    VStack(alignment: .leading) {
      Text(title).font(.headline)
      Text(message).font(.subheadline)
    }
    .padding()
    .background(Color.primary.colorInvert())
    .cornerRadius(8)
    .shadow(radius: 4)
    .offset(offset)  // Use the local offset here for preview purposes
  }
}


