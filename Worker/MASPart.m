//
//  MASPart.m
//  Worker
//
//  Created by Matt Andrews on 28/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "MASPart.h"

@implementation MASPart

- (id)initWithObject:(NSDictionary*)object
{
    self = [super initWithObject:object];
    
    if (self) {
        
        NSUInteger count = [object[@"entities"] count];
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++) {
            
            if (object[@"entities"][i][@"vertices"]) {
                
                result[i] = [[MASPolyine alloc] initWithObject:object[@"entities"][i]];
                
            } else if (object[@"entities"][i][@"radius"]) {
                
                result[i] = [[MASCircle alloc] initWithObject:object[@"entities"][i]];
                
            }
            
        }
        
        _entities = result;
        
    }
    
    return self;
    
}

@end
