//
//  CellObjectCollectionView.swift
//  CellObject
//
//  Created by Nihal on 2017-02-09.
//  Copyright © 2017 Wattpad. All rights reserved.
//

import UIKit
import TLIndexPathTools

/// Encapsulates a configuration for setting a data model on the collection view.
class CellObjectCollectionViewConfig  {
    
    /// The data model to set.
    let dataModel: TLIndexPathDataModel
    
    /// Whether the data model should be set animated.
    let animated: Bool
    
    /// The block to call after the data model has been set.
    let completion: ((Void) -> Void)?
    
    init(_ dataModel: TLIndexPathDataModel, _ animated: Bool, _ completion: ((Void) -> Void)?) {
        self.dataModel = dataModel
        self.animated = animated
        self.completion = completion
    }
    
}

/// A view which renders a UICollectionView using only CellObjects.
/// It manages updating of the collection view with new data models.
/// It also implements the CellObjectDelegate protocol.
public class CellObjectCollectionView: UIView {
    
    /// The collection view used to render the CellObjects.
    public let collectionView: UICollectionView
    
    /// The current data model set on the collection view.
    internal(set) public var dataModel: TLIndexPathDataModel = TLIndexPathDataModel()
    
    /// Called when the collection view is scrolled.
    public var onDidScroll: ((UICollectionView) -> Void)?
    
    /// Called when the collection view will be dragged.
    public var onWillBeginDragging: ((UICollectionView) -> Void)?
    
    internal let dummyCellIdentifier = "CellObjectCollectionViewDummyCell"
    internal var pendingDataModels: [CellObjectCollectionViewConfig] = []
    internal var collectionViewIsPerformingUpdates = false
    
    override public init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        commonInit()
    }
    
    public init(frame: CGRect, _ collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        super.init(coder: aDecoder)
        commonInit()
    }
    
    internal func commonInit() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0.0
            layout.minimumInteritemSpacing = 0.0
            layout.sectionInset = UIEdgeInsets.zero
        }
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: dummyCellIdentifier)
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        addSubview(collectionView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.frame = bounds
    }
    
}

extension CellObjectCollectionView {
    
    /// Updates the collection view with the new data model.
    public func setDataModel(_ dataModel: TLIndexPathDataModel, _ animated: Bool) {
        setDataModel(dataModel, animated, nil)
    }
    
    /// Updates the collection view with the new data model and calls the completion block.
    public func setDataModel(_ dataModel: TLIndexPathDataModel, _ animated: Bool, _ completion: ((Void) -> Void)?) {
        if collectionViewIsPerformingUpdates {
            addPendingDataModel(dataModel, animated, completion)
            return
        }
        collectionViewIsPerformingUpdates = true
        let oldDataModel = self.dataModel
        let newDataModel = dataModel
        self.dataModel = dataModel;
        if !animated {
            collectionView.reloadData()
            // Dispatch to next run loop so that the collection view finishes layout.
            DispatchQueue.main.async {
                self.collectionViewIsPerformingUpdates = false
                completion?()
                // We could have a pending data model after the update, so we handle it.
                self.setNextPendingDataModelConfig()
            }
            return;
        }
        let updates = TLIndexPathUpdates.init(oldDataModel: oldDataModel, updatedDataModel: newDataModel)
        updates.performBatchUpdates(on: collectionView) { (finished) in
            self.collectionViewIsPerformingUpdates = false
            completion?()
            // We could have a pending data model after the update, so we handle it.
            self.setNextPendingDataModelConfig()
        }
    }
    
}

extension CellObjectCollectionView {
    
    internal func addPendingDataModel(_ dataModel: TLIndexPathDataModel, _ animated: Bool, _ completion: ((Void) -> Void)?) {
        pendingDataModels.append(CellObjectCollectionViewConfig(dataModel, animated, completion))
    }
    
    internal func setNextPendingDataModelConfig() {
        if let config = nextPendingDataModelConfig() {
            setDataModel(config.dataModel, config.animated, config.completion)
        }
    }
    
    internal func nextPendingDataModelConfig() -> CellObjectCollectionViewConfig? {
        if let config = pendingDataModels.first {
            pendingDataModels.remove(at: 0)
            return config
        }
        return nil
    }

}

extension CellObjectCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let cellObject = dataModel.item(at: indexPath) as? CellObject, let sizeBlock = cellObject.sizeBlock {
            var inset: UIEdgeInsets
            if let sectionInfo = dataModel.sectionInfo(forSection: indexPath.section) as? CellObjectSectionInfo,
                let sectionInset = sectionInfo.inset {
                inset = sectionInset
            } else if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
                inset = layout.sectionInset
            } else {
                inset = .zero
            }
            return sizeBlock(CGSize(width: collectionView.bounds.width - inset.left - inset.right,
                                    height: collectionView.bounds.height - inset.top - inset.bottom))
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let sectionInfo = dataModel.sectionInfo(forSection: section) as? CellObjectSectionInfo,
            let spacing = sectionInfo.minimumLineSpacing {
            return spacing
        }
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.minimumLineSpacing
        }
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let sectionInfo = dataModel.sectionInfo(forSection: section) as? CellObjectSectionInfo,
            let spacing = sectionInfo.minimumInteritemSpacing {
            return spacing
        }
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.minimumInteritemSpacing
        }
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        if let sectionInfo = dataModel.sectionInfo(forSection: section) as? CellObjectSectionInfo,
            let inset = sectionInfo.inset {
            return inset
        }
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.sectionInset
        }
        return UIEdgeInsets.zero
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataModel.numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModel.numberOfRows(inSection: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var identifier = dummyCellIdentifier
        let item = dataModel.item(at: indexPath)
        if let cellObject = item as? CellObject {
            identifier = String(describing: cellObject.cellClass)
            if let cellObject = cellObject as? CellObjectNib {
                collectionView.register(UINib(nibName: cellObject.cellNib, bundle: nil), forCellWithReuseIdentifier: identifier)
            } else {
                collectionView.register(cellObject.cellClass, forCellWithReuseIdentifier: identifier)
            }
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        (dataModel.item(at: indexPath) as? CellObject)?.configBlock?(cell)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return (dataModel.item(at: indexPath) as? CellObjectSelect)?.shouldSelectBlock?() ?? true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (dataModel.item(at: indexPath) as? CellObjectSelect)?.selectBlock?()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        (dataModel.item(at: indexPath) as? CellObjectSelect)?.deselectBlock?()
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (dataModel.item(at: indexPath) as? CellObjectDisplay)?.willDisplayBlock?(cell)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (dataModel.item(at: indexPath) as? CellObjectDisplay)?.didEndDisplayingBlock?(cell)
    }
    
}

extension CellObjectCollectionView: CellObjectDelegate {
    
    public func cellObjectReload(_ cellObject: CellObject) {
        if let indexPath = dataModel.indexPath(forItem: cellObject) {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    public func cellObjectCell(_ cellObject: CellObject) -> UICollectionViewCell? {
        if let indexPath = dataModel.indexPath(forItem: cellObject) {
            if let cell = collectionView.cellForItem(at: indexPath) {
                if type(of: cell) == cellObject.cellClass {
                    return cell
                }
            }
        }
        return nil
    }
    
    public func cellObjectSizeChanged(_ cellObject: CellObject) {
        collectionView.collectionViewLayout.invalidateLayout()
    }

}

extension CellObjectCollectionView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onDidScroll?(collectionView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        onWillBeginDragging?(collectionView)
    }
    
}
