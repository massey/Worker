//
//  MASPart.h
//  Worker
//
//  Created by Matt Andrews on 28/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MASGeometry.h"
#import "DXFReader.h"

@class MASPolyline;
@class MASEntity;
@class MASMaterial;

@interface MASPart : NSObject

@property NSString *id;

@property MASMaterial *material;
@property MASPolyline *polyline;
@property NSNumber *depth;
@property NSMutableArray *entities;
@property NSArray *hardware;

@property BOOL flipped;
@property NSNumber *rotation;
@property NSNumber *grainDirection;

- (id)initWithObject:(NSDictionary*)object;
- (id)initWithMASEntity:(MASEntity*)polyline;
- (id)initWithDXFEntity:(DXFEntity*)entity;

- (NSNumber*)cost;
- (NSNumber*)area;
- (NSNumber*)cutLength;

- (void)writeDrillingFile;
//- (void)moveFrom:(MASPoint*)basepoint toDestination:(MASPoint*)destination;

//- (void)rotateAtBasepoint:(MASPoint*)basepoint throughAngle:(NSNumber*)angle;

@end
