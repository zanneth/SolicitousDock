//
//  Solicitous_DockAppDelegate.h
//  Solicitous Dock
//
//  Created by Charles Magahern on 12/16/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesWindowController.h"

@interface Solicitous_DockAppDelegate : NSObject <NSApplicationDelegate> {
    BOOL dockHidden;
    int toggleAppsOpenCount;
    
    NSMutableArray *toggleApps;
    PreferencesWindowController *preferencesWindow;
    
    NSStatusItem *statItem;
}

@property (nonatomic, assign) BOOL dockHidden;
@property (nonatomic, assign) int toggleAppsOpenCount;

@property (nonatomic, retain) NSMutableArray *toggleApps;
@property (nonatomic, retain) PreferencesWindowController *preferencesWindow;

@end
