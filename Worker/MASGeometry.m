//
//  MASGeometry.m
//  Worker
//
//  Created by Matt Andrews on 28/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "MASGeometry.h"

@implementation MASGeometry

- (NSDictionary*)decodeLayerString:(NSString*)layer
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    NSArray *params = [layer componentsSeparatedByString:@"-"];
    
    for (int i = 0; i < [params count]; i++) {
        
        if ([params[i] hasPrefix:@"F"]) {
            
            [result setObject:[NSNumber numberWithInt:[[params[i] substringFromIndex:1] intValue]]
                       forKey:@"face"];
            
        }
        
        if ([params[i] hasPrefix:@"D"]) {
            
            [result setObject:[NSNumber numberWithInt:[[params[i] substringFromIndex:1] intValue]]
                       forKey:@"depth"];
            
        }
        
    }
    
    return result;
}


@end


@implementation MASPoint

- (id)initWithObject:(NSDictionary*)object
{
    self = [super init];
    if (self) {
        _x = [object[@"x"] intValue];
        _y = [object[@"y"] intValue];
    }
    
    return self;
}

@end


@implementation MASPolyline

- (id)initWithArray:(NSArray*)array
{
    self = [super init];
    if (self) {
        
        NSUInteger count = [array count];
        
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++) {
            
            result[i] = [[MASPoint alloc] initWithObject:array[i]];
            
        }
        
        _vertices = result;
        
    }
    return self;
}

@end
