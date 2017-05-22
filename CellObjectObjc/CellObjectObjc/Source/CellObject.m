//
//  CellObject.m
//  CellObjectObjc
//
//  Created by Nihal on 2017-05-11.
//  Copyright © 2017 Wattpad Corp. All rights reserved.
//

#import "CellObject.h"

@implementation CellObjectComponent

- (instancetype)initWithClass:(Class)cellClass {
    self = [super init];
    if (self) {
        _cellClass = cellClass;
    }
    return self;
}

@end

@implementation XX

@synthesize cellObjectComponent = _cellObjectComponent;
@synthesize cellNib = _cellNib;

- (instancetype)init {
    self = [super init];
    if (self) {
        _cellObjectComponent = [[CellObjectComponent alloc] initWithClass:[UICollectionViewCell class]];
        _cellNib = @"";
    }
    return self;

}

@end
