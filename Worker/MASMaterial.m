//
//  MASMaterial.m
//  Worker
//
//  Created by Matt Andrews on 19/08/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "MASMaterial.h"
#import "Worker.h"
#import "AppDelegate.h"

@implementation MASMaterial

- (id)initWithLayerString:(NSString*)string
{
    self = [super init];
    if (self) {
        
        _cost = [self materialCost:string];
        
    }
    
    return self;
}


// Claculate material cost from part layer
- (NSNumber*)materialCost:(NSString*)layer
{
    double cost = 0.0;
    
    NSArray *params = [layer componentsSeparatedByString:@"-"];
    NSDictionary *material;
    
    for (int i = 0; i < [params count]; i++) {
        
        if ([params[i] hasPrefix:@"M"]) {
            material = [WORKER materialsData][[params[i] substringFromIndex:1]];
            cost += [material[@"cost"] doubleValue];
            
        }
        
        if ([params[i] hasPrefix:@"C"]) {
            material = [WORKER materialsData][@"coatings"][[params[i] substringWithRange:NSMakeRange(1, 3)]];
            cost += [material[@"cost"] doubleValue];
            
            material = [WORKER materialsData][@"coatings"][[params[i] substringWithRange:NSMakeRange(4, 3)]];
            cost += [material[@"cost"] doubleValue];
            
        }
        
    }
    
    return [NSNumber numberWithDouble:cost];
}


@end
