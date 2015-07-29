//
//  MASGeometry.h
//  Worker
//
//  Created by Matt Andrews on 28/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MASGeometry : NSObject

@end


@interface MASPoint : MASGeometry

@property int x;
@property int y;

@end


@interface MASPolyline : MASGeometry

@property NSArray *vertices;

- (id)initWithArray:(NSArray*)array;

- (NSNumber*)area;

@end


@interface MASCircle : MASGeometry

@property MASPoint *centre;
@property int *radius;

- (id)initWithObject:(NSDictionary*)object;

@end
