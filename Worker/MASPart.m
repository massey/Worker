 //
//  MASPart.m
//  Worker
//
//  Created by Matt Andrews on 28/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "Worker.h"
#import "AppDelegate.h"
#import "MASPart.h"
#import "MASPolyline.h"
#import "MASEntity.h"
#import "MASMaterial.h"

@implementation MASPart

#pragma mark - Initialisers

- (id)initWithObject:(NSDictionary*)object
{
    self = [super init];
    
    if (self) {
        
        NSUInteger count = [object[@"entities"] count];
        
        _entities = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++) {
            _entities[i] = [[MASEntity alloc] initWithObject:object[@"entities"][i]];
            
        }
        
        _material = object[@"material"];
        
        //_polyline = [[MASPolyline alloc] initWithArray:object[@"vertices"]];
        
    }
    
    return self;
    
}


- (id)initWithMASEntity:(MASEntity *)entity
{
    self = [super init];
    
    if (self) {
        
        _entities = [[NSMutableArray alloc] init];
        _polyline = [entity geometry];
        _depth = [self decodeLayerString:[entity layer]][@"depth"];
        _material = [self decodeLayerString:[entity layer]][@"material"];
        
    }
    
    return self;
}


- (id)initWithDXFEntity:(DXFEntity*)entity
{
    self = [super init];
    
    if (self) {
        
        NSDictionary *layerParams = [self decodeLayerString:[NSString stringWithUTF8String:entity->geometry.polyline.layer]];
        DXFEntity *entities = entity->entities;
        
        _id = [NSString stringWithUTF8String:entity->geometry.polyline.handle];
        _material = [[MASMaterial alloc] initWithLayerString:[NSString stringWithUTF8String:entity->geometry.polyline.layer]];
        _polyline = [[MASPolyline alloc] initWithDXFPolyline:&entity->geometry.polyline];
        _depth = layerParams[@"depth"];
        _entities = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < entity->entityCount; i++) {
            
            [_entities addObject:[[MASEntity alloc] initWithDXFEntity:&entities[i]]];
            
        }
        
    }
    
    return self;
}


#pragma mark - Worker related methods

- (NSArray*)entitiesForDrilling
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_entities count]; i++) {
        
        if ([[_entities[i] face] integerValue] < 5) {
            [result addObject:_entities[i]];
            
        }
        
    }
    
    return result;
    
}


- (NSDictionary*)decodeLayerString:(NSString*)layer
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSArray *params = [layer componentsSeparatedByString:@"-"];
    
    for (int i = 0; i < [params count]; i++) {
        
        if ([params[i] hasPrefix:@"D"]) {
            [result setObject:[NSNumber numberWithInt:[[params[i] substringFromIndex:1] intValue]]
                       forKey:@"depth"];
            
        }
        
        if ([params[i] hasPrefix:@"M"]) {
            [result setObject:[[NSString alloc] initWithString:[params[i] substringFromIndex:1]] forKey:@"material"];
            
        }
        
    }
    
    return result;
}


- (NSNumber*)cost
{
    return [NSNumber numberWithDouble:[[self area] doubleValue] * [[[self material] cost] doubleValue]];
}


- (NSNumber*)area
{
    NSNumber *area = [_polyline areaSquareMetres];
    
    return area;
}


- (NSNumber*)cutLength
{
    double cutLength = 0.0;
    
    cutLength += [[_polyline perimeterMetres] doubleValue];
    
    for (int i = 0; i < [_entities count]; i++) {
        if ([[_entities[i] layer] isNotEqualTo:@"0"]) {
            if ([[_entities[i] geometry] isKindOfClass:[MASPolyline class]]) {
                cutLength += [[[_entities[i] geometry] perimeterMetres] doubleValue];
                
            } else if ([[_entities[i] geometry] isKindOfClass:[MASCircle class]]) {
                cutLength += 0.1;
                
            }
        }
    }
    
    return [NSNumber numberWithDouble:cutLength];
}


- (void)writeDrillingFile
{
    NSArray *entities = [self entitiesForDrilling];
    
    // If there are no entities for drilling terminate here
    if ([entities count] == 0) {
        return;
    }
    
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *layer = [[NSMutableString alloc] init];
    
    [string appendString:[MASEntity DXFPairString:@0 value:@"SECTION"]];
    [string appendString:[MASEntity DXFPairString:@2 value:@"ENTITIES"]];
    [string appendString:[MASEntity DXFPairString:@0 value:@"LWPOLYLINE"]];
    
    [layer appendString:[WORKER machineLayerPrefix]];
    [layer appendString:@"B8"];
    [layer appendString:[NSString stringWithFormat:@"D%@", _depth]];
    [string appendString:[MASEntity DXFPairString:@8 value:layer]];
    [string appendString:[_polyline DXFString]];
    
    for (int i = 0; i < [entities count]; i++) {
        [string appendString:[entities[i] DXFString]];
        
    }
    
    [string appendString:[MASEntity DXFPairString:@0 value:@"ENDSEC"]];
    [string appendString:[MASEntity DXFPairString:@0 value:@"EOF"]];
    
    NSLog(@"%@", string);
    
    NSString *dest = [NSString stringWithFormat:@"/Users/mattandrews/testDrills/%@.dxf", _id];
    
    [string writeToFile:dest atomically:NO encoding:NSUTF8StringEncoding error:NULL];
}


@end










