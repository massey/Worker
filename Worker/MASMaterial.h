//
//  MASMaterial.h
//  Worker
//
//  Created by Matt Andrews on 19/08/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MASMaterial : NSObject

@property NSArray  *elements;
@property NSNumber *cost;
@property NSNumber *price;

- (id)initWithLayerString:(NSString*)string;

@end
