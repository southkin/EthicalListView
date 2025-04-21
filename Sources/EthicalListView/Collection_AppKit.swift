//
//  Collection_AppKit.swift
//  EthicalListView
//
//  Created by kin on 4/21/25.
//

import SwiftUI
#if os(macOS)
import AppKit

class CollectionCell_AppKit<Content: View>: NSCollectionViewItem {
    var hostingView: NSHostingView<Content>?

    func configure(with view: Content) {
        self.view.subviews.forEach {
            $0.removeFromSuperview()
        }
        if let hostingView = hostingView {
            hostingView.removeFromSuperview()
        }
        let newHostingView = NSHostingView(rootView: view)
        newHostingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(newHostingView)
        NSLayoutConstraint.activate([
            newHostingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            newHostingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            newHostingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            newHostingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        self.hostingView = newHostingView
    }
}

struct CollectionView_AppKit<Item, Content>: NSViewControllerRepresentable where Content: View {
    var items: [Item]
    let onLastItemAppear: (() -> Void)?
    let content: (Item) -> Content
    let scrollDirection: NSCollectionView.ScrollDirection
    var estimatedItemSize: CGSize = .zero
    
    func makeCoordinator() -> Coordinator {
        Coordinator(items: items, content: content, onLastItemAppear: onLastItemAppear)
    }
    func measureSize<T: View>(_ view: T) -> CGSize {
        let hosting = NSHostingView(rootView: view)
        return hosting.intrinsicContentSize
    }
    func makeNSViewController(context: Context) -> NSViewController {
        let layout = NSCollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        layout.estimatedItemSize = estimatedItemSize

        let collectionView = NSCollectionView()
        collectionView.collectionViewLayout = layout
        collectionView.delegate = context.coordinator
        collectionView.dataSource = context.coordinator
        collectionView.register(CollectionCell_AppKit<AnyView>.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("CollectionCell"))

        let scrollView = NSScrollView()
        scrollView.documentView = collectionView
        scrollView.hasVerticalScroller = true

        let viewController = NSViewController()
        viewController.view = scrollView
        context.coordinator.collectionView = collectionView

        return viewController
    }

    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {
        context.coordinator.updateItems(items)
        context.coordinator.collectionView?.reloadData()
    }

    class Coordinator: NSObject, NSCollectionViewDelegate, NSCollectionViewDataSource {
        var items: [Item]
        let content: (Item) -> Content
        let onLastItemAppear: (() -> Void)?
        weak var collectionView: NSCollectionView?

        init(items: [Item], content: @escaping (Item) -> Content, onLastItemAppear: (() -> Void)?) {
            self.items = items
            self.content = content
            self.onLastItemAppear = onLastItemAppear
        }

        func updateItems(_ newItems: [Item]) {
            self.items = newItems
        }

        func numberOfSections(in collectionView: NSCollectionView) -> Int {
            1
        }

        func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
            items.count
        }

        func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
            guard let cell = collectionView.makeItem(
                withIdentifier: NSUserInterfaceItemIdentifier("CollectionCell"),
                for: indexPath
            ) as? CollectionCell_AppKit<AnyView> else {
                return NSCollectionViewItem()
            }
            let item = items[indexPath.item]
            cell.configure(with: AnyView(content(item)))
            if indexPath.item == items.count - 1 {
                onLastItemAppear?()
            }

            return cell
        }
    }
    init(
        items: [Item],
        onLastItemAppear: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content,
        scrollDirection: NSCollectionView.ScrollDirection = .vertical
    ) {
        self.items = items
        self.onLastItemAppear = onLastItemAppear
        self.content = content
        self.scrollDirection = scrollDirection

        if let first = items.first {
            let view = content(first)
            self.estimatedItemSize = measureSize(view)
        }
    }
}

#endif
