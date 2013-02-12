//
//  Solicitous_DockAppDelegate.m
//  Solicitous Dock
//
//  Created by Charles Magahern on 12/16/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "Solicitous_DockAppDelegate.h"
#import <ApplicationServices/ApplicationServices.h>

extern OSStatus CoreDockSetAutoHideEnabled(Boolean isEnabled);

@implementation Solicitous_DockAppDelegate
@synthesize dockHidden, toggleAppsOpenCount;
@synthesize toggleApps, preferencesWindow;


#pragma mark Menu Actions

- (void)aboutAction:(id)sender {
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:sender];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void)preferencesAction:(id)sender {
    if (!preferencesWindow)
        preferencesWindow = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];
    
    [[preferencesWindow window] makeKeyAndOrderFront:self];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void)quitAction:(id)sender {
    [[NSApplication sharedApplication] terminate:sender];
}

- (void)debug_toggleAction:(id)sender {
    [self toggleShowDock];
}

#pragma mark -


#pragma mark Helper Methods

- (void)toggleShowDock {
    dockHidden = !dockHidden;
    CoreDockSetAutoHideEnabled(dockHidden);
}

- (BOOL)applicationBundleIdentifierIsAToggle:(NSString *)bundleIdentifier {
	BOOL willHide = NO;
    for (NSDictionary *app in toggleApps)
        willHide |= [bundleIdentifier isEqualToString:[app objectForKey:@"Bundle Identifier"]];
	return willHide;
}

- (void)addWorkspaceObservers {
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
														   selector:@selector(workspaceApplicationDidLaunch:)
															   name:NSWorkspaceWillLaunchApplicationNotification object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(workspaceApplicationDidQuit:)
                                                               name:NSWorkspaceDidTerminateApplicationNotification object:nil];
	
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(workspaceApplicationDidBecomeActive:)
                                                               name:NSWorkspaceDidActivateApplicationNotification object:nil];
}

- (void)addStatusBarItems {
    statItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    [statItem setToolTip:@"Solicitous Dock"];
    [statItem setImage:[NSImage imageNamed:@"menu-icon.png"]];
    [statItem setHighlightMode:YES];
    
    NSMenu *menu = [[NSMenu allocWithZone:[NSMenu menuZone]] init];
    
    NSMenuItem *aboutItem = [menu addItemWithTitle:@"About Solicitous Dock" action:@selector(aboutAction:) keyEquivalent:@""];
    [aboutItem setTarget:self];
    [menu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *preferencesItem = [menu addItemWithTitle:@"Preferences..." action:@selector(preferencesAction:) keyEquivalent:@""];
    [preferencesItem setTarget:self];
    NSMenuItem *quitItem = [menu addItemWithTitle:@"Quit" action:@selector(quitAction:) keyEquivalent:@""];
    [quitItem setTarget:self];
    
#ifdef DEBUG_ENABLED
    NSMenuItem *toggleItem = [menu addItemWithTitle:@"DEBUG_ToggleShow" action:@selector(debug_toggleAction:) keyEquivalent:@""];
    [toggleItem setTarget:self];
#endif
    
    [statItem setMenu:menu];
    [menu release];
}

#pragma mark -


#pragma mark Workspace Notification Delegate Methods

- (void)workspaceApplicationDidLaunch:(id)sender {
    NSNotification *notification = (NSNotification *) sender;
    NSString *identifier = [[notification userInfo] objectForKey:@"NSApplicationBundleIdentifier"];
    
    if ([self applicationBundleIdentifierIsAToggle:identifier]) {
        if (!dockHidden)
            [self toggleShowDock];
        toggleAppsOpenCount++;
    }
}

- (void)workspaceApplicationDidQuit:(id)sender {
    NSNotification *notification = (NSNotification *) sender;
    NSString *identifier = [[notification userInfo] objectForKey:@"NSApplicationBundleIdentifier"];
    
    if ([self applicationBundleIdentifierIsAToggle:identifier])
        toggleAppsOpenCount--;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HideShowWhenSwitching"]) {
        if ([self applicationBundleIdentifierIsAToggle:identifier] && dockHidden && toggleAppsOpenCount == 0)
            [self toggleShowDock];
    }
}

- (void)workspaceApplicationDidBecomeActive:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HideShowWhenSwitching"]) {
        NSNotification *notification = (NSNotification *) sender;
        NSString *identifier = [[[notification userInfo] objectForKey:@"NSWorkspaceApplicationKey"] bundleIdentifier];
        
        if ([self applicationBundleIdentifierIsAToggle:identifier]) {
            if (!dockHidden)
                [self toggleShowDock];
        } else {
            if (dockHidden)
                [self toggleShowDock];
        }
    }
}

#pragma mark -


#pragma mark Initializer

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSArray *settings = [[NSUserDefaults standardUserDefaults] objectForKey:@"ToggleApps"];
    if (settings != nil)
        toggleApps = [[NSMutableArray alloc] initWithArray:settings];
    else
        toggleApps = [[NSMutableArray alloc] init];
    
    NSDictionary *dockPlist = [[NSDictionary alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.apple.dock.plist"]];
    dockHidden = [[dockPlist objectForKey:@"autohide"] boolValue];
    [dockPlist release];
    
    toggleAppsOpenCount = 0;
    for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications]) {
        if ([self applicationBundleIdentifierIsAToggle:[app bundleIdentifier]])
            toggleAppsOpenCount++;
    }
    
    [self addWorkspaceObservers];
    [self addStatusBarItems];
	
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DefaultsExist"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DefaultsExist"];
        [[NSUserDefaults standardUserDefaults] setObject:toggleApps forKey:@"ToggleApps"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HideShowWhenSwitching"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark -


- (void)dealloc {
    [toggleApps release];
    [preferencesWindow release];
    [statItem release];
    
    [super dealloc];
}

@end
