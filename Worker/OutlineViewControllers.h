//
//  OutlineViewController.h
//  Worker
//
//  Created by Matt Andrews on 3/08/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

@interface JobsOutlineViewController : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (weak) IBOutlet NSOutlineView *outlineView;

@end


@interface WorkOutlineViewController : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>

@end
