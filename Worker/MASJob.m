//
//  MASJob.m
//  Worker
//
//  Created by Matt Andrews on 3/08/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "MASJob.h"
#import "MASUnit.h"

@implementation MASJob

- (id)initWithObject:(NSDictionary*)object
{
    self = [super init];
    
    if (self) {
        
        NSUInteger count = [object[@"units"] count];
        
        _units = [[NSMutableArray alloc] initWithCapacity:count];
        _parts = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < count; i++) {
            _units[i] = [[MASUnit alloc] initWithObject:object[@"units"][i]];
        }
        
    }
    
    return self;
    
}


- (id)initWithParts:(NSArray*)parts
{
    self = [super init];
    
    if (self) {
        
        _parts = [[NSMutableArray alloc] init];
        _units = [[NSMutableArray alloc] init];
        
        [_parts addObjectsFromArray:parts];
        
    }
    
    return self;
    
}


- (NSArray*)allParts
{
    NSUInteger count = [_units count];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        
        [result addObjectsFromArray:[_units[i] parts]];
        
    }
    
    if ([_parts count] > 0) {
        
        [result addObjectsFromArray:_parts];
        
    }
    
    return [[NSArray alloc] initWithArray:result];
}


- (NSNumber*)cost
{
    double cost = 0.0;
    
    for (int i = 0; i < [_units count]; i++) {
        cost += [[_units[i] cost] doubleValue];
        
    }
    
    for (int i = 0; i < [_parts count]; i++) {
        cost += [[_parts[i] cost] doubleValue];
        
    }
    
    return [NSNumber numberWithDouble:cost];
}


- (NSNumber*)area
{
    double area = 0.0;
    
    for (int i = 0; i < [_units count]; i++) {
        area += [[_units[i] area] doubleValue];
        
    }
    
    for (int i = 0; i < [_parts count]; i++) {
        area += [[_parts[i] area] doubleValue];
        
    }
    
    return [NSNumber numberWithDouble:area];
}


- (NSNumber*)cutLength
{
    double cutLength = 0.0;
    
    for (int i = 0; i < [_units count]; i++) {
        cutLength += [[_units[i] area] doubleValue];
        
    }
    
    for (int i = 0; i < [_parts count]; i++) {
        cutLength += [[_parts[i] cutLength] doubleValue];
        
    }
    
    return [NSNumber numberWithDouble:cutLength];
}


@end









