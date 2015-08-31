//
//  MASEntity.h
//  Worker
//
//  Created by Matt Andrews on 28/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DXFReader.h"

@class MASWorker;

@interface MASEntity : NSObject

@property NSString *layer;
@property NSNumber *face;
@property id geometry;
@property NSNumber *depth;

- (id)initWithObject:(NSDictionary*)object;
- (id)initWithDXFEntity:(DXFEntity*)entity;

-(NSString*)DXFString;

+ (NSString*)DXFPairString:(NSNumber*)groupCode value:(NSString*)value;

@end
