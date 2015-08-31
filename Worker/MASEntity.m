//
//  MASEntity.m
//  Worker
//
//  Created by Matt Andrews on 28/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "Worker.h"
#import "AppDelegate.h"
#import "MASEntity.h"
#import "MASGeometry.h"
#import "MASPolyline.h"

@implementation MASEntity


- (id)initWithObject:(NSDictionary*)object
{
    self = [super init];
    
    if (self) {
        
        if (object[@"vertices"]) {
            
            _geometry = [[MASPolyline alloc] initWithArray:object[@"vertices"]];
            
        }
        
        if (object[@"radius"]) {
            
            _geometry = [[MASCircle alloc] initWithObject:object];
            
        }
        
        _layer = object[@"layer"];
        
        _face = [self decodeLayerString:_layer][@"face"];
        
    }
    
    return self;
    
}


- (id)initWithDXFEntity:(DXFEntity*)entity
{
    self = [super init];
    
    if (self) {
        
        if (entity->type == DXFTypePolyline) {
            _geometry = [[MASPolyline alloc] initWithDXFPolyline:&entity->geometry.polyline];
            _layer = [[NSString alloc] initWithCString:entity->geometry.polyline.layer
                                              encoding:NSUTF8StringEncoding];
        }
        if (entity->type == DXFTypeCircle) {
            _geometry = [[MASCircle alloc] initWithDXFCircle:&entity->geometry.circle];
            _layer = [[NSString alloc] initWithCString:entity->geometry.circle.layer
                                              encoding:NSUTF8StringEncoding];
        }
        
        if ([_layer isEqualToString:@"0"]) {
            _face = [NSNumber numberWithInt:-1];
            _depth = [NSNumber numberWithInt:0];
        } else {
            NSDictionary *layerParams = [self decodeLayerString:_layer];
            _face = layerParams[@"face"];
            _depth = layerParams[@"depth"];
        }
    }
    
    return self;
}


#pragma mark Private


- (NSDictionary*)decodeLayerString:(NSString*)layer
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSArray *params = [layer componentsSeparatedByString:@"-"];
    
    // Set depth to zero when no depth is given
    [result setObject:[NSNumber numberWithInt:0] forKey:@"depth"];
    
    for (int i = 0; i < [params count]; i++) {
        
        if ([params[i] hasPrefix:@"F"]) {
            [result setObject:[NSNumber numberWithInt:[[params[i] substringFromIndex:1] intValue]]
                       forKey:@"face"];
            
        }
        
        if ([params[i] hasPrefix:@"D"]) {
            [result setObject:[NSNumber numberWithInt:[[params[i] substringFromIndex:1] intValue]]
                       forKey:@"depth"];
            
        }
        
        if ([params[i] hasPrefix:@"C"]) {
            [result setObject:[NSNumber numberWithInt:[[params[i] substringFromIndex:1] intValue]]
                       forKey:@"coatings"];
            
        }
        
    }
    
    return result;
}


- (NSString*)DXFString
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *layer = [[NSMutableString alloc] init];
    
    if ([_geometry isKindOfClass:[MASPolyline class]]) {
        [string appendString:[MASEntity DXFPairString:@0 value:@"LWPOLYLINE"]];
    } else if ([_geometry isKindOfClass:[MASCircle class]]) {
        [string appendString:[MASEntity DXFPairString:@0 value:@"CIRCLE"]];
    }
    
    // Build machining layer
    if ([_face intValue] < 0) {
        [layer appendString:@"0"];
    } else {
        [layer appendString:[NSString stringWithFormat:@"TCHW%@", _face]];
        [layer appendString:[self operationCode]];
        [layer appendString:[self toolCode]];
        if ([_depth integerValue] > 0) {
            [layer appendString:[NSString stringWithFormat:@"D%@", [_depth stringValue]]];
        }
    }
    
    [string appendString:[MASEntity DXFPairString:@8 value:layer]];
    [string appendString:[_geometry DXFString]];
    return [NSString stringWithString:string];
}


- (NSString*)operationCode
{
    NSString *string;
    
    if ([_geometry isKindOfClass:[MASPolyline class]]) {
        if ([_face intValue] > 0 && [_face intValue] < 5) {
            string = @"B2";
        } else {
            string = @"B1";
        }
    } else if ([_geometry isKindOfClass:[MASCircle class]]) {
        string = @"B2";
    }
    
    return string;
}


- (NSString*)toolCode
{
    NSString *string;
    
    if ([_geometry isKindOfClass:[MASPolyline class]]) {
        if ([_face intValue] > 0 && [_face intValue] < 5) {
            string = @"";
        } else {
            string = [NSString stringWithFormat:@"TCD$%@$", [WORKER defaultRoutToolCode]];
        }
    } else if ([_geometry isKindOfClass:[MASCircle class]]) {
        string = [NSString stringWithFormat:@"TCD$%@$", [WORKER toolCodeForBoreDiameter:[_geometry radius] * 2]];
    }
    
    return string;
}


+ (NSString*)DXFPairString:(NSNumber*)groupCode value:(NSString *)value
{
    NSString *string = [NSString stringWithFormat:@"%3d\n", [groupCode intValue]];
    string = [string stringByAppendingString:[NSString stringWithFormat:@"%@\n", value]];
    return string;
}


@end

















