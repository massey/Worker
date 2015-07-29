//
//  MASPart.h
//  Worker
//
//  Created by Matt Andrews on 28/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MASGeometry.h"
#import "MASEntity.h"

@interface MASPart : MASPolyline

@property NSString *material;
@property id geometry;
@property NSMutableArray *entities;

@property BOOL flipped;
@property NSNumber *rotation;
@property NSNumber *grainDirection;

- (id)initWithObject:(NSDictionary*)object;

- (NSNumber*)perimeter;

- (NSArray*)getEntitiesForFace:(NSString*)face;

- (void)moveFromBasepoint:(MASPoint*)basepoint toDestination:(MASPoint*)destination;

- (void)rotateAtBasepoint:(MASPoint*)basepoint throughAngle:(NSNumber*)angle;

@end
