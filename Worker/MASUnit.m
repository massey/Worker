//
//  MASUnit.m
//  Worker
//
//  Created by Matt Andrews on 3/08/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "MASUnit.h"
#import "MASPart.h"

@implementation MASUnit

- (id)initWithObject:(NSDictionary*)object
{
    self = [super init];
    
    if (self) {
        
        NSUInteger count = [object[@"parts"] count];
        
        _parts = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++) {
            _parts[i] = [[MASPart alloc] initWithObject:object[@"parts"][i]];
        }
        
    }
    
    return self;
    
}


- (NSNumber*)cost
{
    double cost = 0.0;
    
    for (int i = 0; i < [_parts count]; i++) {
        
        cost += [[_parts[i] cost] doubleValue];
        
    }
    
    return [NSNumber numberWithDouble:cost];
}


- (NSNumber*)area
{
    double area = 0.0;
    
    for (int i = 0; i < [_parts count]; i++) {
        
        area += [[_parts[i] area] doubleValue];
        
    }
    
    return [NSNumber numberWithDouble:area];
}


- (NSNumber*)cutLength
{
    double cutLength = 0.0;
    
    for (int i = 0; i < [_parts count]; i++) {
        
        cutLength += [[_parts[i] area] doubleValue];
        
    }
    
    return [NSNumber numberWithDouble:cutLength];
}


@end
