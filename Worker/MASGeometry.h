//
//  MASGeometry.h
//  Worker
//
//  Created by Matt Andrews on 28/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MASPoint : NSObject

@property int x;
@property int y;

- (void)moveByVector:(id)vector;

- (void)rotateAtBasePoint:(MASPoint*)basepoint throughAngle:(NSNumber*)angle;

@end


@interface MASGeometry : NSObject

@property NSNumber *face;
@property NSString *layer;

- (void)moveByVector:(id)vector;

- (void)rotateAtBasePoint:(MASPoint*)basepoint throughAngle:(NSNumber*)angle;

@end


@interface MASPolyline : MASGeometry

@property NSArray *vertices;

- (id)initWithObject:(NSDictionary*)object;

- (NSNumber*)area;

@end


@interface MASCircle : MASGeometry

@property MASPoint *centre;
@property int *radius;

- (id)initWithObject:(NSDictionary*)object;

@end
