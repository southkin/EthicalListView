# EthicalListView

> "Always reuse your cells and release memory properly when displaying many items. That’s ethics." — Julius Caesar

SwiftUI’s built-in list views don’t release memory properly.  
So I wrapped `UICollectionView` to fix that.

Then I realized it doesn’t work on macOS,  
so I wrapped `NSCollectionView` too.  

## ✨ Features
- SwiftUI-style API, works out of the box
- Efficient under-the-hood rendering using UICollectionView / NSCollectionView
- Smooth performance with proper cell reuse and memory management
- `onLastItemAppear` support for infinite scrolling
- Cross-platform: iOS + macOS

## 📦 Installation (Swift Package Manager)
1. Open Xcode > File > Add Packages...
1. Enter repository URL:
    ```markdown
    https://github.com/your-username/EthicalListView.git
    ```
1. In your Swift file:
    ```swift
    import EthicalListView
    ```

## 🚀 Usage Examples

### Vertical List
```swift
EthicalListView.Vertical(items: yourItems) { item in
    Text("\(item)")
        .frame(width: 100, height: 100)
        .background(Color.gray.opacity(0.2))
}
```

### Horizontal List
```swift
EthicalListView.Horizontal(items: yourItems) { item in
    YourCustomView(item: item)
}
.frame(height: 200)
```

### Infinite Scroll
```swift
EthicalListView.Vertical(items: items) { item in
    Text("\(item)")
        .frame(width: 100, height: 100)
        .background(Color.gray.opacity(0.2))
}
.onLastItemAppear {
    loadMoreItems()
}
```

## 💡 Behavior Notes
- If items are fixed-size with .frame, estimation reflects that.
- For dynamic content, layout adapts via intrinsic sizing.
- UIKit uses UICollectionView; AppKit uses NSCollectionView.

## 💻 Platform Support
- iOS 13+
- macOS 11+