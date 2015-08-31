//
//  worker.m
//  Worker
//
//  Created by Matt Andrews on 27/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "Worker.h"
#import "MASJob.h"
#import "MASUnit.h"
#import "MASPart.h"
#import "MASEntity.h"
#import "MASSheet.h"
#import "DXFReader.h"

@interface MASWorker ()

@property (weak) NSArray *rawData;
@property NSBundle *bundle;

@end

@implementation MASWorker

- (id)init
{
    self = [super init];
    
    if (self) {
        _data = [[NSMutableArray alloc] init];
        _parts = [[NSMutableArray alloc] init];
        _sheets = [[NSMutableArray alloc] init];
        
        _bundle = [NSBundle mainBundle];
        
        NSURL *machineURL = [_bundle URLForResource:@"machine" withExtension:@"json"];
        NSURL *materialsURL = [_bundle URLForResource:@"materials" withExtension:@"json"];
        NSURL *pricingURL = [_bundle URLForResource:@"pricing" withExtension:@"json"];
        NSURL *processURL = [_bundle URLForResource:@"process" withExtension:@"json"];
        NSURL *toolsURL = [_bundle URLForResource:@"tools" withExtension:@"json"];
        
        _machineData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:machineURL]
                                                       options:NSJSONReadingMutableContainers
                                                         error:nil];
        _materialsData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:materialsURL]
                                                   options:NSJSONReadingMutableContainers
                                                     error:nil];
        _pricingData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:pricingURL]
                                                   options:NSJSONReadingMutableContainers
                                                     error:nil];
        _processData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:processURL]
                                                       options:NSJSONReadingMutableContainers
                                                         error:nil];
        _toolData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:toolsURL]
                                                    options:NSJSONReadingMutableContainers
                                                      error:nil];

    }
    
    return self;
}

// Get all parts to write their drilling files
- (void)writeDrillingFiles {

    NSMutableArray *parts = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_data count]; i++) {
        
        if ([_data[i] isKindOfClass:[MASJob class]]) {
            [parts addObjectsFromArray:[_data[i] parts]];
        } else if ([_data[i] isKindOfClass:[MASPart class]]) {
            [parts addObjectsFromArray:_data[i]];
        }
    }
    
    for (int i = 0; i < [parts count]; i++) {
        
        [parts[i] writeDrillingFile];
        
    }
}

- (void)loadDXF:(NSURL*)url
{
    // Extract entities from DXF file
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    
    DXFParts *DXFPartsInfo = DXFRead([[url path] UTF8String]);
    DXFEntity *DXFParts = DXFPartsInfo->parts;
    

    for (int i = 0; i < DXFPartsInfo->nParts; i++) {
        
        [parts addObject:[[MASPart alloc] initWithDXFEntity:&DXFParts[i]]];
        
    }
    
    //DXFFree(dxfParts);
    
    MASJob *newJob = [[MASJob alloc] initWithParts:parts];
    
    [_data addObject:newJob];
    
}

- (void)loadJSON:(NSURL*)url
{
    _rawData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url]
                                                      options:NSJSONReadingMutableContainers
                                                        error:nil];
}

- (void)buildParts
{
    NSUInteger count = [_rawData count];
    
    if (!(count > 0)) {
        return;
    }
    
    for (int i = 0; i < count; i++) {
        
        if (_rawData[i][@"units"]) {
            [_data addObject:[[MASJob alloc] initWithObject:_rawData[i]]];
        }
        
        if (_rawData[i][@"parts"]) {
            [_data addObject:[[MASUnit alloc] initWithObject:_rawData[i]]];
        }
        
        if (_rawData[i][@"material"]) {
            [_data addObject:[[MASPart alloc] initWithObject:_rawData[i]]];
        }
    }
}


- (NSArray*)getParts;
{
    NSUInteger count = [_data count];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        
        if ([_data[i] isKindOfClass:[MASPart class]]) {
            [result addObject:_data[i]];
        } else {
            [result addObjectsFromArray:[_data[i] getParts]];
        }
        
    }
    
    return [[NSArray alloc] initWithArray:result];
}





- (NSString*)defaultRoutToolCode
{
    return [NSString stringWithString:_machineData[@"defaultRoutTool"]];
}



- (NSString*)toolCodeForBoreDiameter:(double)diameter
{
    __block NSString *toolCode;
    
    [_toolData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj[@"diameter"] doubleValue] == diameter) {
            toolCode = key;
            *stop = 1;
        }
    }];
    
    return toolCode;
}


- (NSString*)machineLayerPrefix
{
    return _machineData[@"machineLayerPrefix"];
}

@end




























