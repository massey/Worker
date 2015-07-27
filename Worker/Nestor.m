//
//  Nestor.m
//  Worker
//
//  Created by Matt Andrews on 27/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "Nestor.h"

@implementation Nestor

@end


//
// Point
//

@implementation MASPoint

- (instancetype)initWithObject:(NSDictionary*)object
{
    self = [super init];
    
    if (self) {
        
        _x = object[@"x"];
        _y = object[@"y"];
        
    }
    
    return self;
}

@end


//
// MASEntity
//

@implementation MASEntity

- (instancetype)initWithObject:(NSDictionary *)object
{
    self = [super init];
    
    if (self) {
        
        _type = object[@"type"];
        
        _layer = object[@"layer"];
        
    }
    
    return self;
}

@end


//
// Polyline
//

@implementation MASPolygon

- (id)initWithObject:(NSDictionary*)object
{
    self = [super initWithObject:object];
    if (self) {
        
        NSUInteger count = [object[@"vertices"] count];
        
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++) {
            
            result[i] = [[MASPoint alloc] initWithObject:object[@"vertices"][i]];
            
        }
        
        _vertices = result;
        
    }
    return self;
}


// Calculate the area of the polygon
-(NSNumber*)area
{
    double result, xi, yi, xj, yj;
    
    long int count = [_vertices count];
    
    for (int i = 0, j; i < count; i++) {
        
        j = (i + 1) % count; // Current and next iterators
        
        xi = [_vertices[i][@"x"] doubleValue];
        yi = [_vertices[i][@"y"] doubleValue];
        xj = [_vertices[j][@"x"] doubleValue];
        yj = [_vertices[j][@"y"] doubleValue];
        
        result += xi * yj - xj * yi;
    }
    
    return [[NSNumber alloc] initWithDouble:result];
}

@end


//
// Circle
//

@implementation MASCircle

- (instancetype)initWithObject:(NSDictionary*)object
{
    self = [super initWithObject:object];
    
    if (self) {
        
        _radius = object[@"radius"];
        
        _center = [[MASPoint alloc] initWithObject:object[@"centre"]];
        
    }
    
    return self;
}

@end


//
// Part
//

@implementation MASPart

- (id)initWithObject:(NSDictionary*)object
{
    self = [super initWithObject:object];
    
    if (self) {
        
        NSUInteger count = [object[@"entities"] count];
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++) {
            
            if ([object[@"type"]  isEqual: @"polyline"]) {
                
                result[i] = [[MASPolygon alloc] initWithObject:object[@"entities"][i]];
                
            } else if ([object[@"type"]  isEqual: @"circle"]) {
                
                result[i] = [[MASCircle alloc] initWithObject:object[@"entities"][i]];
                
            }
            
        }
        
        _entities = result;
        
        _material = object[@"material"];
        
    }
    
    return self;
    
}

@end


//
// Space
//

@implementation MASSpace

@end