//
//  AppDelegate.h
//  Worker
//
//  Created by Matt Andrews on 27/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Worker.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property MASWorker *worker;
@property (weak) IBOutlet NSOutlineView *jobsOutlineView;

- (IBAction)loadJSON:(id)sender;

- (IBAction)buildParts:(id)sender;

- (IBAction)writeDrillingFiles:(id)sender;

@end

