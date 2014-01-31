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
extern NSString * const SDPreferencesIconStyleKey;
extern NSString * const SDApplicationBundleIdentifierKey;
extern NSString * const SDApplicationNameKey;

typedef NS_ENUM(NSUInteger, SDMenuIconStyle) {
    SDMenuIconStyleBlackAndWhite = 0, // default
    SDMenuIconStyleColor,
};

@interface Solicitous_DockAppDelegate : NSObject <NSApplicationDelegate, PreferencesWindowDelegate>

@property (nonatomic, assign) BOOL dockHidden;
@property (nonatomic, assign) int toggleAppsOpenCount;

@property (nonatomic, strong) NSMutableArray *toggleApps;
@property (nonatomic, strong) PreferencesWindowController *preferencesWindow;

@end
