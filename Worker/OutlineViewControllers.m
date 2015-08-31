//
//  OutlineViewController.m
//  Worker
//
//  Created by Matt Andrews on 3/08/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "OutlineViewControllers.h"
#import "MASJob.h"
#import "MASUnit.h"
#import "MASPart.h"
#import "MASEntity.h"
#import "MASSheet.h"

@implementation JobsOutlineViewController

- (instancetype)init
{
    self = [super init];
    return self;
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (!item) {
        return [[[[NSApp delegate] worker] data] objectAtIndex:index];
        
    } else if ([item isKindOfClass:[MASJob class]]) {
        if (index < [[item units] count]) {
            return [[item units] objectAtIndex:index];
            
        } else {
            return [[item parts] objectAtIndex:index - [[item units] count]];
            
        }
        
    } else if ([item isKindOfClass:[MASUnit class]]) {
        return [[item parts] objectAtIndex:index];
        
    } else if ([item isKindOfClass:[MASPart class]]) {
        return [[item entities] objectAtIndex:index];
    }
    
    return nil;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if (!item) {
        return [[[[NSApp delegate] worker] data] count] > 0;
        
    } else if ([item isKindOfClass:[MASJob class]]) {
        return ([[item units] count] > 0) || ([[item parts] count] > 0);
        
    } else if ([item isKindOfClass:[MASUnit class]]) {
        return [[item parts] count] > 0;
        
    } else if ([item isKindOfClass:[MASPart class]]) {
        return [[item entities] count] > 0;
        
    }
    
    return NO;
}


- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    NSInteger result;
    
    if (!item) {
        result = [[[[NSApp delegate] worker] data] count];
        
    } else if ([item isKindOfClass:[MASJob class]]) {
        result = [[item units] count] + [[item parts] count];
        
    } else if ([item isKindOfClass:[MASUnit class]]) {
        result = [[item parts] count];
        
    } else if ([item isKindOfClass:[MASPart class]]) {
        result = [[item entities] count];
    }
    
    return result;
}


- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    id result;
    
    if ([item isKindOfClass:[MASJob class]]) {
        result = @"Job";
    } else if ([item isKindOfClass:[MASUnit class]]) {
        result = @"Unit";
    } else if ([item isKindOfClass:[MASPart class]]) {
        result = @"Part";
    } else if ([item isKindOfClass:[MASEntity class]]) {
        result = @"Entity";
    }
    
    return result;
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    id item = [_outlineView itemAtRow:[_outlineView selectedRow]];
    
    if ([item isKindOfClass:[MASEntity class]]) {
        return;
    }
    
    double price = ([[item cost] doubleValue] * 1.4) + ([[item cutLength] doubleValue] * 5);
    
    NSLog(@"Area: %@\nCut length: %@\nCost: %@\nPrice: %f", [item area], [item cutLength], [item cost], price);
}

@end



@implementation WorkOutlineViewController

- (instancetype)init
{
    self = [super init];
    return self;
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (!item) {
        return [[[[NSApp delegate] worker] sheets] objectAtIndex:index];
        
    } else if ([item isKindOfClass:[MASSheet class]]) {
        return [[item parts] objectAtIndex:index];
        
    } else if ([item isKindOfClass:[MASPart class]]) {
        return [[item entities] objectAtIndex:index];
        
    }
    
    return nil;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if (!item) {
        return [[[[NSApp delegate] worker] sheets] count] > 0;
        
    } else if ([item isKindOfClass:[MASSheet class]]) {
        return [[item parts] count] > 0;
        
    } else if ([item isKindOfClass:[MASPart class]]) {
        return [[item entities] count] > 0;
        
    }
    
    return NO;
}


- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    NSInteger result;
    
    if (!item) {
        result = [[[[NSApp delegate] worker] sheets] count];
        
    } else if ([item isKindOfClass:[MASSheet class]]) {
        result = [[item parts] count];
        
    } else if ([item isKindOfClass:[MASPart class]]) {
        result = [[item entities] count];
    }
    
    return result;
}


- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    id result;
    
    if ([item isKindOfClass:[MASSheet class]]) {
        result = @"Sheet";
    } else if ([item isKindOfClass:[MASPart class]]) {
        result = @"Part";
    } else if ([item isKindOfClass:[MASEntity class]]) {
        result = @"Entity";
    }
    
    return result;
}

@end
