// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct EthicalListView {
    public struct Vertical<Item, Content>: View where Content: View {
        let items: [Item]
        let content: (Item) -> Content
        var onLastItemAppear: (() -> Void)?

        public init(
            items: [Item],
            onLastItemAppear: (() -> Void)? = nil,
            @ViewBuilder content: @escaping (Item) -> Content
        ) {
            self.items = items
            self.onLastItemAppear = onLastItemAppear
            self.content = content
        }

        public var body: some View {
            #if os(iOS)
            CollectionView_UIKit(
                items: items,
                scrollDirection: .vertical,
                onLastItemAppear: onLastItemAppear,
                content: content
            )
            #elseif os(macOS)
            CollectionView_AppKit(items: items, onLastItemAppear: onLastItemAppear, content: content, scrollDirection: .vertical)
            #else
            Text("Unsupported platform")
            #endif
        }
    }
    public struct Horizontal<Item, Content>: View where Content: View {
        let items: [Item]
        let content: (Item) -> Content
        var onLastItemAppear: (() -> Void)?

        public init(
            items: [Item],
            onLastItemAppear: (() -> Void)? = nil,
            @ViewBuilder content: @escaping (Item) -> Content
        ) {
            self.items = items
            self.onLastItemAppear = onLastItemAppear
            self.content = content
        }

        public var body: some View {
            #if os(iOS)
            CollectionView_UIKit(
                items: items,
                scrollDirection: .horizontal,
                onLastItemAppear: onLastItemAppear,
                content: content
            )
            #elseif os(macOS)
            CollectionView_AppKit(items: items, onLastItemAppear: onLastItemAppear, content: content, scrollDirection: .horizontal)
            #else
            Text("Unsupported platform")
            #endif
        }
    }
}
extension EthicalListView.Vertical {
    func onLastItemAppear(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onLastItemAppear = action
        return copy
    }
}
extension EthicalListView.Horizontal {
    func onLastItemAppear(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onLastItemAppear = action
        return copy
    }
}

struct EthicalListViewPreview_Previews: PreviewProvider {
    static var previews: some View {
        let items = (0...300).map { "\($0)" }
        VStack {
            EthicalListView.Horizontal(items: items) { item in
                Text("\(item)")
                    .padding()
                    .frame(width: 100, height: 100, alignment: .center)
                    .background(Color.yellow.opacity(0.2))
            }
            .frame(height:220)
            EthicalListView.Vertical(items: items) { item in
                Text("\(item)")
                    .padding()
                    .frame(width: 127, height: 127, alignment: .center)
                    .background(Color.blue.opacity(0.2))
            }
        }
        
    }
}
