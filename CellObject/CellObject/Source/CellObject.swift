//
//  CellObject.swift
//  CellObject
//
//  Created by Nihal on 2017-02-02.
//  Copyright © 2017 Wattpad. All rights reserved.
//

import UIKit

/// Objects which conform to this protocol are responsible
/// for configuring the cells used to display them.
@objc public protocol CellObject: class {
    
    var cellObjectComponent: CellObjectComponent { get set }
    
}

/// Objects which conform to this protocol are responsible
/// for handling events related to displaying of the cell.
@objc public protocol CellObjectDisplay: class {
    
    var cellObjectDisplayComponent: CellObjectDisplayComponent { get set }
    
}

/// Objects which conform to this protocol are responsible
/// for handling events related to selection of the cell.
@objc public protocol CellObjectSelect: class {
    
    var cellObjectSelectComponent: CellObjectSelectComponent { get set }
    
}

/// Objects which conform to this protocol are responsible
/// for providing the nib name to use for the cell.
@objc public protocol CellObjectNib {
    
    var cellNib: String { get }
    
}

/// Cell object delegates are responsible for providing
/// and updating the cell used by the cell object.
@objc public protocol CellObjectDelegate: NSObjectProtocol {
    
    /// Reloads the cell.
    func cellObjectReload(_ cellObject: CellObject)
    
    /// Returns the cell used to display the cell object.
    func cellObjectCell(_ cellObject: CellObject) -> UICollectionViewCell?
    
    /// Refreshes the size of the cell.
    func cellObjectSizeChanged(_ cellObject: CellObject)
    
}

/// Component which encapsulates the information needed to display a cell object.
@objc public class CellObjectComponent: NSObject {
    
    /// The class of the cell to use for the cell object.
    public var cellClass: AnyClass
    
    /// The block which configures the cell.
    public var configBlock: ((UICollectionViewCell) -> Void)?
    
    /// The block which returns the size for the cell.
    public var sizeBlock: ((CGSize) -> CGSize)?
    
    /// The delegate of the cell object.
    public weak var cellObjectDelegate: CellObjectDelegate?
    
    public init(_ cellClass: AnyClass) {
        self.cellClass = cellClass
    }
    
}

/// Helper extension which forwards calls to the cellObjectComponent.
public extension CellObject {
    
    public var cellClass: AnyClass {
        get { return cellObjectComponent.cellClass }
        set { cellObjectComponent.cellClass = newValue }
    }

    public var configBlock: ((UICollectionViewCell) -> Void)? {
        get { return cellObjectComponent.configBlock }
        set { cellObjectComponent.configBlock = newValue }
    }

    public var sizeBlock: ((CGSize) -> CGSize)? {
        get { return cellObjectComponent.sizeBlock }
        set { cellObjectComponent.sizeBlock = newValue }
    }

    public weak var cellObjectDelegate: CellObjectDelegate? {
        get { return cellObjectComponent.cellObjectDelegate }
        set { cellObjectComponent.cellObjectDelegate = newValue }
    }
    
}

/// Component which encapsulates the information related to the displaying of a cell object.
@objc public class CellObjectDisplayComponent: NSObject {
    
    /// Called before the cell becomes visible.
    public var willDisplayBlock: ((UICollectionViewCell) -> Void)?
    
    /// Called after the cell is no longer visible.
    public var didEndDisplayingBlock: ((UICollectionViewCell) -> Void)?
    
    public override init() {}
    
}

/// Helper extension which forwards calls to the cellObjectDisplayComponent.
public extension CellObjectDisplay {
    
    public var willDisplayBlock: ((UICollectionViewCell) -> Void)? {
        get { return cellObjectDisplayComponent.willDisplayBlock }
        set { cellObjectDisplayComponent.willDisplayBlock = newValue }
    }
    
    public var didEndDisplayingBlock: ((UICollectionViewCell) -> Void)? {
        get { return cellObjectDisplayComponent.didEndDisplayingBlock }
        set { cellObjectDisplayComponent.didEndDisplayingBlock = newValue }
    }
    
}

/// Component which encapsulates the information related to the selection of a cell object.
@objc public class CellObjectSelectComponent: NSObject {
    
    /// The block which returns if the cell should be selected.
    public var shouldSelectBlock: ((Void) -> Bool)?
    
    /// Called when the cell is selected.
    public var selectBlock: ((Void) -> Void)?
    
    /// Called when the cell is deselected.
    public var deselectBlock: ((Void) -> Void)?
    
    public override init() {}
    
}

/// Helper extension which forwards calls to the cellObjectSelectComponent.
public extension CellObjectSelect {
    
    public var shouldSelectBlock: ((Void) -> Bool)? {
        get { return cellObjectSelectComponent.shouldSelectBlock }
        set { cellObjectSelectComponent.shouldSelectBlock = newValue }
    }
    
    public var selectBlock: ((Void) -> Void)? {
        get { return cellObjectSelectComponent.selectBlock }
        set { cellObjectSelectComponent.selectBlock = newValue }
    }
    
    public var deselectBlock: ((Void) -> Void)? {
        get { return cellObjectSelectComponent.deselectBlock }
        set { cellObjectSelectComponent.deselectBlock = newValue }
    }
    
}
