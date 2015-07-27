//
//  AppDelegate.m
//  Worker
//
//  Created by Matt Andrews on 27/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "AppDelegate.h"
#import "Worker.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property MASWorker *worker;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    _worker = [[MASWorker alloc] init];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)loadJSON:(id)sender {
    
    NSOpenPanel *loadJSON = [NSOpenPanel openPanel];
    
    [loadJSON beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        if (result == NSFileHandlingPanelOKButton) {
            
            NSLog(@"The filename was: %@", loadJSON.URLs[0]);
            
            _worker.data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:loadJSON.URLs[0]]
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
            
        }
        
    }];
    
}

- (IBAction)logData:(id)sender {
    
    [_worker logData];
    
}

- (IBAction)buildParts:(id)sender {
    
    [_worker buildParts];
    
}

@end
