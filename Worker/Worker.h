//
//  worker.h
//  Worker
//
//  Created by Matt Andrews on 27/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MASWorker : NSObject

@property  int numberOfPartsToNest;

@property id data;

@property NSMutableArray *parts;

@property NSMutableArray *sheets;

/*-----------*/

- (void)logData;

- (void)buildParts;

@end
