//
//  worker.m
//  Worker
//
//  Created by Matt Andrews on 27/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "Worker.h"

@implementation MASWorker

- (void)logData {

    NSLog(@"Hi%@", _data);
    
}

- (void)buildParts {
    
    NSUInteger count = [_data count];
    
    if (!count > 0) {
        
        return;
        
    }
    
    for (int i = 0; i < count; i++) {
        
        if (_data[i][@"material"]) {
            
            [_parts addObject:[[MASPart alloc] initWithObject:_data[i]]];
            
            _numberOfPartsToNest = [NSNumber numberWithInt:[_numberOfPartsToNest intValue] + 1];
            
        }
        
    }
    
}

@end
