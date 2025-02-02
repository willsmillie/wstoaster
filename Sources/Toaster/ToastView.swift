import SwiftUI

public struct ToastView: View {
  var type: ToastStyle
  var title: String
  var message: String
  var onCancelTapped: (() -> Void)

  let cornerRadius = 16.0

  public var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .center) {
        Image(systemName: type.iconFileName)
          .resizable()
          .aspectRatio(1, contentMode: .fit)
          .frame(width: 24, height: 24)
          .foregroundColor(type.themeColor)
          .padding(.leading, 8)

        VStack(alignment: .leading,spacing: 4) {
          if (!title.isEmpty) {
            Text(title)
              .foregroundStyle(.primary)
              .font(.system(.body, design: .default).weight(.semibold))
          }

          if (!message.isEmpty) {
            Text(message)
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }

        Spacer(minLength: 10)

        Button {
          onCancelTapped()
        } label: {
          Image(systemName: "xmark")
            .foregroundColor(Color.black)
        }
      }
      .padding(8)
    }
    .background(Material.regular)
    .overlay(
      Rectangle()
        .fill(type.themeColor)
        .frame(width: 6)
        .clipped()
        .padding(4),
      alignment: .leading
    )
    .frame(minWidth: 0, maxWidth: 600)
    .cornerRadius(8)
    .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 1)
    .padding(.horizontal, 16)
  }
}

#Preview {
  NavigationView {
    List {
      ForEach(1..<10) {
        Text("Item \($0)")
      }
    }
  }.overlay {
    ToastView(type: .info, title: "Hello World", message: "TESTING ONE TWO THREE", onCancelTapped: {

    })
  }
}
