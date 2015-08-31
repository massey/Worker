//
//  worker.h
//  Worker
//
//  Created by Matt Andrews on 27/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//
// MASWorker is intended to be a singleton which controls access to imported
// data, configuration files and app specific methods

#import <Cocoa/Cocoa.h>

#define WORKER [(AppDelegate*)[NSApp delegate] worker]

@interface MASWorker : NSObject

@property NSMutableArray *data;
@property NSMutableArray *parts;
@property NSMutableArray *sheets;

// Worker data properties
@property NSDictionary *machineData;
@property NSDictionary *materialsData;
@property NSDictionary *pricingData;
@property NSDictionary *processData;
@property NSDictionary *toolData;

- (void)loadJSON:(NSURL*)url;
- (void)buildParts;
- (NSArray*)getParts;
- (void)loadDXF:(NSURL*)url;

- (void)writeDrillingFiles;

- (NSString*)defaultRoutToolCode;
- (NSString*)toolCodeForBoreDiameter:(double)diameter;
- (NSString*)machineLayerPrefix;
//- (NSDictionary*)getAreasByMaterial;

//- (NSNumber*)getTotalCuttingLength;

@end
