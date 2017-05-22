//
//  CellObjectCollectionView.m
//  CellObjectObjc
//
//  Created by Nihal on 2017-05-14.
//  Copyright © 2017 Wattpad Corp. All rights reserved.
//

#import "CellObjectCollectionView.h"

#import <TLIndexPathTools/TLIndexPathTools.h>

#import "CellObject.h"
#import "CellObjectSectionInfo.h"

NS_ASSUME_NONNULL_BEGIN

/// Encapsulates a configuration for setting a data model on the collection view.
@interface CellObjectCollectionViewConfig : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDataModel:(TLIndexPathDataModel *)dataModel
                         animated:(BOOL)animated;

/// The data model to set.
@property (nonatomic, strong, readonly) TLIndexPathDataModel *dataModel;

/// Whether the data model should be set animated.
@property (nonatomic, readonly) BOOL animated;

@end

NS_ASSUME_NONNULL_END

@implementation CellObjectCollectionViewConfig

- (instancetype)initWithDataModel:(TLIndexPathDataModel *)dataModel
                         animated:(BOOL)animated {
    self = [super init];
    if (self) {
        _dataModel = dataModel;
        _animated = animated;
    }
    return self;
}

@end

NS_ASSUME_NONNULL_BEGIN

@interface CellObjectCollectionView ()

@property (nonatomic, strong) TLIndexPathDataModel *dataModel;
@property (nonatomic, strong, readonly) NSMutableArray<CellObjectCollectionViewConfig *> *pendingDataModels;
@property (nonatomic) BOOL collectionViewIsPerformingUpdates;
@property (nonatomic, copy) NSString *dummyIdentifier;

@end

NS_ASSUME_NONNULL_END

@implementation CellObjectCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0.0;
        layout.minimumLineSpacing = 0.0;
        layout.sectionInset = UIEdgeInsetsZero;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0.0;
        layout.minimumLineSpacing = 0.0;
        layout.sectionInset = UIEdgeInsetsZero;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionView:(UICollectionView *)collectionView {
    self = [super initWithFrame:frame];
    if (self) {
        _collectionView = collectionView;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _pendingDataModels = [[NSMutableArray alloc] init];
    _dummyIdentifier = @"dummyIdentifier";
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:_dummyIdentifier];
    [_collectionView registerClass:[UICollectionViewCell class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:_dummyIdentifier];
    [_collectionView registerClass:[UICollectionViewCell class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
               withReuseIdentifier:_dummyIdentifier];
    [_collectionView reloadData];
    [_collectionView layoutIfNeeded];
    [self addSubview:_collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.collectionView.frame = self.bounds;
}

- (void)setDataModel:(TLIndexPathDataModel *)dataModel animated:(BOOL)animated {
    if (self.collectionViewIsPerformingUpdates) {
        [self addPendingDataModel:dataModel animated:animated];
        return;
    }
    self.collectionViewIsPerformingUpdates = YES;
    TLIndexPathDataModel *oldDataModel = self.dataModel;
    TLIndexPathDataModel *newDataModel = dataModel;
    self.dataModel = dataModel;
    if (!animated) {
        [self.collectionView reloadData];
        typeof(self) __weak weakSelf = self;
        // Dispatch to next run loop so that the collection view finishes layout.
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.collectionViewIsPerformingUpdates = NO;
            // We could have a pending data model after the dispatch, so we handle it.
            [weakSelf setNextPendingDataModelConfig];
        });
        return;
    }
    typeof(self) __weak weakSelf = self;
    TLIndexPathUpdates *updates =
    [[TLIndexPathUpdates alloc] initWithOldDataModel:oldDataModel updatedDataModel:newDataModel];
    [updates performBatchUpdatesOnCollectionView:self.collectionView
                                      completion:^(BOOL finished) {
                                          weakSelf.collectionViewIsPerformingUpdates = NO;
                                          // We could have a pending data model after the update, so we handle it.
                                          [weakSelf setNextPendingDataModelConfig];
                                      }];
}

- (void)addPendingDataModel:(TLIndexPathDataModel *)dataModel animated:(BOOL)animated {
    if (dataModel) {
        CellObjectCollectionViewConfig *config;
        config = [[CellObjectCollectionViewConfig alloc] initWithDataModel:dataModel animated:animated];
        if (config) {
            [self.pendingDataModels addObject:config];
        }
    }
}

- (void)setNextPendingDataModelConfig {
    CellObjectCollectionViewConfig *config = [self nextPendingDataModelConfig];
    if (config) {
        [self setDataModel:config.dataModel animated:config.animated];
    }
}

- (nullable CellObjectCollectionViewConfig *)nextPendingDataModelConfig {
    CellObjectCollectionViewConfig *config = self.pendingDataModels.firstObject;
    if (config) {
        [self.pendingDataModels removeObjectAtIndex:0];
    }
    return config;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.dataModel numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataModel numberOfRowsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = self.dummyIdentifier;
    id item = [self.dataModel itemAtIndexPath:indexPath];
    if ([item conformsToProtocol:@protocol(CellObject)]) {
        identifier = NSStringFromClass([[item cellObjectComponent] cellClass]);
        if ([item conformsToProtocol:@protocol(CellObjectNib)]) {
            [collectionView registerNib:[UINib nibWithNibName:[item cellNib] bundle:nil] forCellWithReuseIdentifier:identifier];
        } else {
            [collectionView registerClass:[[item cellObjectComponent] cellClass] forCellWithReuseIdentifier:identifier];
        }
    }
    UICollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if ([item conformsToProtocol:@protocol(CellObject)]) {
        if ([item cellObjectComponent].configBlock) {
            [item cellObjectComponent].configBlock(cell);
        }
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self.dataModel itemAtIndexPath:indexPath];
    if ([item conformsToProtocol:@protocol(CellObject)]) {
        if ([item cellObjectComponent].shouldSelectBlock) {
            return [item cellObjectComponent].shouldSelectBlock();
        }
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self.dataModel itemAtIndexPath:indexPath];
    if ([item conformsToProtocol:@protocol(CellObject)]) {
        if ([item cellObjectComponent].selectBlock) {
            [item cellObjectComponent].selectBlock();
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self.dataModel itemAtIndexPath:indexPath];
    if ([item conformsToProtocol:@protocol(CellObject)]) {
        if ([item cellObjectComponent].deselectBlock) {
            [item cellObjectComponent].deselectBlock();
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self.dataModel itemAtIndexPath:indexPath];
    if ([item conformsToProtocol:@protocol(CellObject)]) {
        if ([item cellObjectComponent].sizeBlock) {
            return [item cellObjectComponent].sizeBlock(collectionView.bounds.size);
        }
    }
    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CellObjectSectionInfo *sectionInfo = (CellObjectSectionInfo *)[self.dataModel sectionInfoForSection:section];
    if ([sectionInfo isKindOfClass:[CellObjectSectionInfo class]]) {
        return sectionInfo.minimumLineSpacing;
    }
    if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        return [(UICollectionViewFlowLayout *)collectionViewLayout minimumLineSpacing];
    }
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    CellObjectSectionInfo *sectionInfo = (CellObjectSectionInfo *)[self.dataModel sectionInfoForSection:section];
    if ([sectionInfo isKindOfClass:[CellObjectSectionInfo class]]) {
        return sectionInfo.minimumInteritemSpacing;
    }
    if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        return [(UICollectionViewFlowLayout *)collectionViewLayout minimumInteritemSpacing];
    }
    return 0.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    CellObjectSectionInfo *sectionInfo = (CellObjectSectionInfo *)[self.dataModel sectionInfoForSection:section];
    if ([sectionInfo isKindOfClass:[CellObjectSectionInfo class]]) {
        return sectionInfo.inset;
    }
    if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        return [(UICollectionViewFlowLayout *)collectionViewLayout sectionInset];
    }
    return UIEdgeInsetsZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    CellObjectSectionInfo *sectionInfo =
    (CellObjectSectionInfo *)[self.dataModel sectionInfoForSection:indexPath.section];
    id<CellObject> object = [kind isEqualToString:UICollectionElementKindSectionHeader] ? sectionInfo.header : sectionInfo.footer;
    NSString *identifier = self.dummyIdentifier;
    if (object) {
        identifier = NSStringFromClass([[object cellObjectComponent] cellClass]);
        [collectionView registerClass:[[object cellObjectComponent] cellClass]
           forSupplementaryViewOfKind:kind
                  withReuseIdentifier:identifier];
    }
    UICollectionViewCell *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:identifier
                                              forIndexPath:indexPath];
    if ([object cellObjectComponent].configBlock) {
        [object cellObjectComponent].configBlock(view);
    }
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    CellObjectSectionInfo *sectionInfo = (CellObjectSectionInfo *)[self.dataModel sectionInfoForSection:section];
    if ([sectionInfo isKindOfClass:[CellObjectSectionInfo class]]) {
        id<CellObject> object = sectionInfo.header;
        if ([object cellObjectComponent].sizeBlock) {
            return [object cellObjectComponent].sizeBlock(collectionView.bounds.size);
        }
    }
    if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        return [(UICollectionViewFlowLayout *)collectionViewLayout headerReferenceSize];
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section {
    CellObjectSectionInfo *sectionInfo = (CellObjectSectionInfo *)[self.dataModel sectionInfoForSection:section];
    if ([sectionInfo isKindOfClass:[CellObjectSectionInfo
                                    class]]) {
        id<CellObject> object = sectionInfo.footer;
        if ([object cellObjectComponent].sizeBlock) {
            return [object cellObjectComponent].sizeBlock(collectionView.bounds.size);
        }
    }
    if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        return [(UICollectionViewFlowLayout *)collectionViewLayout footerReferenceSize];
    }
    return CGSizeZero;
}

- (void)dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

@end
