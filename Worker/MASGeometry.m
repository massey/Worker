//
//  MASGeometry.m
//  Worker
//
//  Created by Matt Andrews on 28/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <math.h>
#import "MASGeometry.h"
#import "MASEntity.h"


@implementation MASGeometry

@end


@implementation MASPoint

- (id)initWithObject:(NSDictionary*)object
{
    self = [super init];
    if (self) {
        _x = [object[@"x"] doubleValue];
        _y = [object[@"y"] doubleValue];
        _bulge = [object[@"bulge"] doubleValue];
    }
    
    return self;
}


- (id)initWithDXFVertex:(DXFVertex*)vertex
{
    self = [super init];
    if (self) {
        _x = round(vertex->x * 100) / 100;
        _y = round(vertex->y * 100) / 100;
        _bulge = vertex->bulge;
    }
    
    return self;
}


- (NSString*)DXFString
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    [string appendString:[MASEntity DXFPairString:@10 value:[NSString stringWithFormat:@"%ld", (long)_x]]];
    [string appendString:[MASEntity DXFPairString:@20 value:[NSString stringWithFormat:@"%ld", (long)_y]]];
    if (_bulge > 0) {
        [string appendString:[MASEntity DXFPairString:@42 value:[NSString stringWithFormat:@"%ld", (long)_bulge]]];
    }
    
    return [NSString stringWithString:string];
}
@end


@implementation MASCircle

- (id)initWithObject:(NSDictionary*)object
{
    self = [super init];
    if (self) {
        _centre = [[MASPoint alloc] initWithObject:object[@"centre"]];
        _radius = [object[@"radius"] integerValue];
    }
    
    return self;
}


- (id)initWithDXFCircle:(DXFCircle*)circle
{
    self = [super init];
    if (self) {
        _centre = [[MASPoint alloc] initWithDXFVertex:&circle->centre];
        _radius = circle->radius;
    }
    
    return self;
}


- (NSString*)DXFString
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    [string appendString:[_centre DXFString]];
    [string appendString:[MASEntity DXFPairString:@40 value:[NSString stringWithFormat:@"%.2f", _radius]]];
    
    return [NSString stringWithString:string];
}

@end
