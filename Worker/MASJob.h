//
//  MASJob.h
//  Worker
//
//  Created by Matt Andrews on 3/08/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MASJob : NSObject

@property NSMutableArray *units;
@property NSMutableArray *parts;

- (id)initWithObject:(NSDictionary*)object;
- (id)initWithParts:(NSArray*)parts;
- (NSArray*)allParts;

- (NSNumber*)cost;
- (NSNumber*)area;
- (NSNumber*)cutLength;
//- (void)getArea;

@end
