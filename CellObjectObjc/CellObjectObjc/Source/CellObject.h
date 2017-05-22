//
//  CellObject.h
//  CellObjectObjc
//
//  Created by Nihal on 2017-05-11.
//  Copyright © 2017 Wattpad Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Objects which conform to this protocol are responsible
/// for providing the nib name to use for the cell.
NS_ASSUME_NONNULL_BEGIN

@protocol CellObjectNib
    
@property (nonatomic, copy) NSString *cellNib;

@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

@protocol CellObject;

/// Cell object delegates are responsible for providing
/// and updating the cell used by the cell object.
@protocol CellObjectDelegate

/// Reloads the cell.
- (void)cellObjectReload:(id<CellObject>)cellObject;

/// Returns the cell used to display the cell object.
- (nullable UICollectionViewCell *)cellObjectCell:(id<CellObject>)cellObject;

/// Refreshes the size of the cell.
- (void)cellObjectSizeChanged:(id<CellObject>)cellObject;

/// Deselects the cell.
- (void)cellObjectDeselect:(id<CellObject>)object;

/// Deletes the cell object.
- (void)cellObjectDelete:(id<CellObject>)object;

@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

/// Component which encapsulates the information needed to display a cell object.
@interface CellObjectComponent: NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithClass:(Class)cellClass;

/// The class of the cell to use for the cell object.
@property (nonatomic, strong) Class cellClass;

/// The block which configures the cell.
@property (nonatomic, copy, nullable) void(^configBlock)(UICollectionViewCell *);

/// The block which returns the size for the cell.
@property (nonatomic, copy, nullable) CGSize(^sizeBlock)(CGSize);

/// The delegate of the cell object.
@property (nonatomic, weak) id<CellObjectDelegate> cellObjectDelegate;

/// Called before the cell becomes visible.
@property (nonatomic, copy, nullable) void(^willDisplayBlock)(UICollectionViewCell *);

/// Called after the cell is no longer visible.
@property (nonatomic, copy, nullable) void(^didEndDisplayingBlock)(UICollectionViewCell *);

/// The block which returns if the cell should be selected.
@property (nonatomic, copy, nullable) BOOL(^shouldSelectBlock)(void);

/// Called when the cell is selected.
@property (nonatomic, copy, nullable) void(^selectBlock)(void);

/// Called when the cell is deselected.
@property (nonatomic, copy, nullable) void(^deselectBlock)(void);

@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

/// Objects which conform to this protocol are responsible for
/// configuring the cells and also handle events related to the cell.
@protocol CellObject

@property (nonatomic, strong) CellObjectComponent *cellObjectComponent;

@end

NS_ASSUME_NONNULL_END

@interface XX : NSObject<CellObject, CellObjectNib>

@end
