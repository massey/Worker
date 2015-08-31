//
//  AppDelegate.m
//  Worker
//
//  Created by Matt Andrews on 27/07/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _window.titleVisibility = NSWindowTitleHidden;
    
    _worker = [[MASWorker alloc] init];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)loadJSON:(id)sender {
    
    NSOpenPanel *loadJSON = [NSOpenPanel openPanel];
    
    [loadJSON setAllowedFileTypes:@[@"json", @"dxf"]];
    
    [loadJSON beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        if (result == NSFileHandlingPanelOKButton) {
            
            if ([[loadJSON.URLs[0] pathExtension] isEqualToString:@"json"]) {
                
                NSLog(@"The filename was: %@", loadJSON.URLs[0]);
                
                [_worker loadJSON:loadJSON.URLs[0]];
                
                [_worker buildParts];
                
                [_jobsOutlineView reloadData];
                
            } else if ([[loadJSON.URLs[0] pathExtension] isEqualToString:@"dxf"]) {
                
                [_worker loadDXF:loadJSON.URLs[0]];
                [_jobsOutlineView reloadData];
                
            }
        }
    }];
}


- (IBAction)buildParts:(id)sender {
    
    [_worker buildParts];
    
}


- (IBAction)writeDrillingFiles:(id)sender
{
    [_worker writeDrillingFiles];
}

@end
