//
//  MASGeometry.h
//  Worker
//
//  Created by Matt Andrews on 28/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXFReader.h"

@class MASEntity;
@class MASPoint;

@interface MASGeometry : NSObject

@end


@interface MASPoint : NSObject

@property double x;
@property double y;
@property double bulge;

- (id)initWithObject:(NSDictionary*)object;
- (id)initWithDXFVertex:(DXFVertex*)vertex;

- (NSString*)DXFString;

@end


@interface MASCircle : MASGeometry

@property MASPoint *centre;
@property double radius;

- (id)initWithObject:(NSDictionary*)object;
- (id)initWithDXFCircle:(DXFCircle*)circle;

- (NSString*)DXFString;

@end
