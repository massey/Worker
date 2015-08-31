//
//  MASUnit.h
//  Worker
//
//  Created by Matt Andrews on 3/08/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MASUnit : NSObject

@property NSMutableArray *parts;

- (id)initWithObject:(NSDictionary*)object;

- (NSNumber*)cost;
- (NSNumber*)area;
- (NSNumber*)cutLength;

@end
