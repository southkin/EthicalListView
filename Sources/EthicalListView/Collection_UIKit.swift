//
//  Collection_UIKit.swift
//  EthicalListView
//
//  Created by kin on 4/21/25.
//

import SwiftUI
#if os(iOS)
import UIKit

class CollectionCell_UIKit: UICollectionViewCell {
    private var hostingController: UIHostingController<AnyView>?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure<T: View>(with view: T) {
        
        hostingController?.view.removeFromSuperview()
        hostingController = UIHostingController(rootView: AnyView(view))
        hostingController!.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingController!.view)

        NSLayoutConstraint.activate([
            hostingController!.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController!.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingController!.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController!.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        hostingController!.view.layoutIfNeeded()
    }
}
/// **✅ 공용 컬렉션 뷰 컨트롤러 (`UICollectionView` 기반)**
struct CollectionView_UIKit<Item, Content>: UIViewControllerRepresentable where Content: View {
    let items: [Item]
    let content: (Item) -> Content
    let scrollDirection: UICollectionView.ScrollDirection
    let onLastItemAppear: (() -> Void)?

    init(
        items: [Item],
        scrollDirection: UICollectionView.ScrollDirection,
        onLastItemAppear: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.scrollDirection = scrollDirection
        self.onLastItemAppear = onLastItemAppear
        self.content = content
    }

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(items: items, content: content)
        coordinator.onLastItemAppear = onLastItemAppear
        return coordinator
    }

    func makeUIViewController(context: Context) -> UICollectionViewController {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        let viewController = UICollectionViewController(collectionViewLayout: layout)
        viewController.collectionView = collectionView
        viewController.collectionView?.register(CollectionCell_UIKit.self, forCellWithReuseIdentifier: "CollectionCell_UIKit")

        viewController.collectionView?.dataSource = context.coordinator
        viewController.collectionView?.delegate = context.coordinator

        return viewController
    }

    func updateUIViewController(_ uiViewController: UICollectionViewController, context: Context) {
        context.coordinator.updateItems(items)
        uiViewController.collectionView?.reloadData()
    }

    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        var items: [Item]
        var content: (Item) -> Content
        var onLastItemAppear: (() -> Void)?

        init(items: [Item], content: @escaping (Item) -> Content) {
            self.items = items
            self.content = content
        }

        func updateItems(_ newItems: [Item]) {
            self.items = newItems
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return items.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell_UIKit", for: indexPath) as! CollectionCell_UIKit
            let item = items[indexPath.item]
            cell.configure(with: content(item))

            // ✅ 마지막 아이템이 나타나면 실행
            if indexPath.item == items.count - 1 {
                onLastItemAppear?()
            }

            return cell
        }
    }
}



#endif
