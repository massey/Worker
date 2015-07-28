//
//  MASEntity.h
//  Worker
//
//  Created by Matt Andrews on 28/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MASGeometry.h"

@interface MASEntity : NSObject

@property NSString *layer;
@property NSNumber *face;
@property id geometry;

- (id)initWithObject:(NSDictionary*)object;

@end
