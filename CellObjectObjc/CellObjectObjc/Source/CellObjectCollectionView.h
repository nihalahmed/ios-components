//
//  CellObjectCollectionView.h
//  CellObjectObjc
//
//  Created by Nihal on 2017-05-14.
//  Copyright © 2017 Wattpad Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLIndexPathDataModel;

NS_ASSUME_NONNULL_BEGIN

/// A view which renders a UICollectionView using only CellObjects.
/// It manages updating of the collection view with new data models.
/// It also implements the CellObjectDelegate protocol.
@interface CellObjectCollectionView : UIView <UICollectionViewDelegate,
                                              UICollectionViewDataSource,
                                              UICollectionViewDelegateFlowLayout>

/// Updates the collection view with the new data model.
- (void)setDataModel:(TLIndexPathDataModel *)dataModel animated:(BOOL)animated;

/// The collection view used to render the CellObjects.
@property (nonatomic, strong, readonly) UICollectionView *collectionView;

/// The current data model set on the collection view.
@property (nonatomic, strong, readonly) TLIndexPathDataModel *dataModel;

@end

NS_ASSUME_NONNULL_END
