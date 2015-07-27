//
//  Nestor.h
//  Worker
//
//  Created by Matt Andrews on 27/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Nestor : NSObject

@end


//
// Point
//

@interface MASPoint : NSObject

@property NSNumber *x;
@property NSNumber *y;

@end


//
// Entity
//

@interface MASEntity : NSObject

@property NSString *type;
@property NSString *layer;

@end


//
// Polyline
//

@interface MASPolygon : MASEntity

@property NSArray *vertices;

/*-------*/

- (NSNumber*)area;

@end


//
// Circle
//

@interface MASCircle : MASEntity

@property NSNumber *radius;
@property MASPoint *center;

@end


//
// Part
//

@interface MASPart : MASPolygon

@property NSString *material;
@property NSArray *entities;

- (id)initWithObject:(NSDictionary*)object;

@end


//
// Space
//

@interface MASSpace : MASPolygon

@end


//
// Space
//

@interface MASSheet : MASPolygon

@end