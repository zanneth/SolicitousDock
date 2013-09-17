//
//  Solicitous_DockAppDelegate.h
//  Solicitous Dock
//
//  Created by Charles Magahern on 12/16/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesWindowController.h"

extern NSString * const SDPreferencesDefaultsExistKey;
extern NSString * const SDPreferencesToggleAppsKey;
extern NSString * const SDPreferencesHideShowWhenSwitchingKey;
extern NSString * const SDApplicationBundleIdentifierKey;
extern NSString * const SDApplicationNameKey;

@interface Solicitous_DockAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, assign) BOOL dockHidden;
@property (nonatomic, assign) int toggleAppsOpenCount;

@property (nonatomic, retain) NSMutableArray *toggleApps;
@property (nonatomic, retain) PreferencesWindowController *preferencesWindow;

@end
