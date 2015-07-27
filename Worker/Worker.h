//
//  worker.h
//  Worker
//
//  Created by Matt Andrews on 27/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Nestor.h"

@interface MASWorker : NSObject

@property NSNumber *numberOfPartsToNest;

@property id data;

@property NSMutableArray *parts;

@property NSMutableArray *sheets;

/*-----------*/

- (void)logData;

- (void)buildParts;

@end
