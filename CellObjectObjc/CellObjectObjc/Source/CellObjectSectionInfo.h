//
//  CellObjectSectionInfo.h
//  CellObjectObjc
//
//  Created by Nihal on 2017-05-14.
//  Copyright © 2017 Wattpad Corp. All rights reserved.
//

#import <TLIndexPathTools/TLIndexPathTools.h>

#import "CellObject.h"

NS_ASSUME_NONNULL_BEGIN

/// Subclass which allows for configuring of the layout of a section.
@interface CellObjectSectionInfo : TLIndexPathSectionInfo

/// The minimum line spacing for the section.
@property (nonatomic) CGFloat minimumLineSpacing;

/// The minimum interitem spacing for the section.
@property (nonatomic) CGFloat minimumInteritemSpacing;

/// The inset for the section.
@property (nonatomic) UIEdgeInsets inset;

/// The cell object used to render the header of the section.
@property (nonatomic, strong, nullable) id<CellObject> header;

/// The cell object used to render the footer of the section.
@property (nonatomic, strong, nullable) id<CellObject> footer;

@end

NS_ASSUME_NONNULL_END
