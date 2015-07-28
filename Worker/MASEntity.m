//
//  MASEntity.m
//  Worker
//
//  Created by Matt Andrews on 28/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "MASEntity.h"

@implementation MASEntity

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


- (id)initWithObject:(NSDictionary*)object
{
    self = [super init];
    
    if (self) {
        
        if (object[@"vertices"]) {
            
            _geometry = [[MASPolyline alloc] initWithObject:object];
            
        }
        
        if (object[@"radius"]) {
            
            _geometry = [[MASCircle alloc] initWithObject:object];
            
        }
        
        _layer = object[@"layer"];
        
        _face = [self decodeLayerString:_layer][@"face"];
        
    }
    
    return self;
    
}

@end
