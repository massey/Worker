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
    self = [super init];
    
    if (self) {
        
        NSUInteger count = [object[@"entities"] count];
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++) {
            result[i] = [[MASEntity alloc] initWithObject:object[@"entities"][i]];
            
        }
        
        self.material = object[@"material"];
        self.entities = result;
        self.geometry = [[MASPolyline alloc] initWithArray:object[@"vertices"]];
        
    }
    
    return self;
    
}

@end
