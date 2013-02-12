//
//  Solicitous_DockAppDelegate.m
//  Solicitous Dock
//
//  Created by Charles Magahern on 12/16/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "Solicitous_DockAppDelegate.h"
#import <ApplicationServices/ApplicationServices.h>

NSString * const SDPreferencesDefaultsExistKey         = @"SDPreferencesDefaultsExistKey";
NSString * const SDPreferencesToggleAppsKey            = @"SDPreferencesToggleAppsKey";
NSString * const SDPreferencesHideShowWhenSwitchingKey = @"SDPreferencesHideShowWhenSwitchingKey";
NSString * const SDApplicationBundleIdentifierKey      = @"SDApplicationBundleIdentifierKey";
NSString * const SDApplicationNameKey                  = @"SDApplicationNameKey";

// private functions in ApplicationServices that alter dock autohide state
extern Boolean CoreDockGetAutoHideEnabled();
extern OSStatus CoreDockSetAutoHideEnabled(Boolean enabled);

@implementation Solicitous_DockAppDelegate {
    BOOL    _dockHidden;
    int     _toggleAppsOpenCount;
    
    NSMutableArray              *_toggleApps;
    PreferencesWindowController *_preferencesWindow;
    NSStatusItem                *_statItem;
}
@synthesize dockHidden = _dockHidden;
@synthesize toggleAppsOpenCount = _toggleAppsOpenCount;
@synthesize toggleApps = _toggleApps;
@synthesize preferencesWindow = _preferencesWindow;

#pragma mark - Menu Actions

- (void)aboutAction:(id)sender {
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:sender];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void)preferencesAction:(id)sender {
    if (!_preferencesWindow) {
        _preferencesWindow = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];
    }
    
    [[_preferencesWindow window] makeKeyAndOrderFront:self];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void)quitAction:(id)sender {
    [[NSApplication sharedApplication] terminate:sender];
}

- (void)debug_toggleAction:(id)sender {
    [self toggleShowDock];
}

#pragma mark - Helper Methods

- (void)toggleShowDock {
    _dockHidden = !_dockHidden;
    CoreDockSetAutoHideEnabled(_dockHidden);
}

- (BOOL)applicationBundleIdentifierIsAToggle:(NSString *)bundleIdentifier {
	BOOL willHide = NO;
    for (NSDictionary *app in _toggleApps) {
        NSString *toggleIdentifier = [app objectForKey:SDApplicationBundleIdentifierKey];
        willHide |= [bundleIdentifier isEqualToString:toggleIdentifier];
    }
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
    _statItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    [_statItem setToolTip:@"Solicitous Dock"];
    [_statItem setImage:[NSImage imageNamed:@"menu-icon.png"]];
    [_statItem setHighlightMode:YES];
    
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
    
    [_statItem setMenu:menu];
    [menu release];
}

#pragma mark - Workspace Notification Delegate Methods

- (void)workspaceApplicationDidLaunch:(id)sender {
    NSNotification *notification = (NSNotification *) sender;
    NSString *identifier = [[notification userInfo] objectForKey:@"NSApplicationBundleIdentifier"];
    
    if ([self applicationBundleIdentifierIsAToggle:identifier]) {
        if (!_dockHidden) {
            [self toggleShowDock];
        }
        _toggleAppsOpenCount++;
    }
}

- (void)workspaceApplicationDidQuit:(id)sender {
    NSNotification *notification = (NSNotification *) sender;
    NSString *identifier = [[notification userInfo] objectForKey:@"NSApplicationBundleIdentifier"];
    
    if ([self applicationBundleIdentifierIsAToggle:identifier]) {
        _toggleAppsOpenCount--;
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:SDPreferencesHideShowWhenSwitchingKey]) {
        if ([self applicationBundleIdentifierIsAToggle:identifier] && _dockHidden && _toggleAppsOpenCount == 0) {
            [self toggleShowDock];
        }
    }
}

- (void)workspaceApplicationDidBecomeActive:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SDPreferencesHideShowWhenSwitchingKey]) {
        NSNotification *notification = (NSNotification *) sender;
        NSString *identifier = [[[notification userInfo] objectForKey:@"NSWorkspaceApplicationKey"] bundleIdentifier];
        
        if ([self applicationBundleIdentifierIsAToggle:identifier]) {
            if (!_dockHidden) {
                [self toggleShowDock];
            }
        } else {
            if (_dockHidden) {
                [self toggleShowDock];
            }
        }
    }
}

#pragma mark - Initializer

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSArray *settings = [[NSUserDefaults standardUserDefaults] objectForKey:SDPreferencesToggleAppsKey];
    if (settings != nil) {
        _toggleApps = [[NSMutableArray alloc] initWithArray:settings];
    } else {
        _toggleApps = [[NSMutableArray alloc] init];
    }
    
    _dockHidden = CoreDockGetAutoHideEnabled();
    
    _toggleAppsOpenCount = 0;
    for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications]) {
        if ([self applicationBundleIdentifierIsAToggle:[app bundleIdentifier]]) {
            _toggleAppsOpenCount++;
        }
    }
    
    [self addWorkspaceObservers];
    [self addStatusBarItems];
	
    if (![[NSUserDefaults standardUserDefaults] boolForKey:SDPreferencesDefaultsExistKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SDPreferencesDefaultsExistKey];
        [[NSUserDefaults standardUserDefaults] setObject:_toggleApps forKey:SDPreferencesToggleAppsKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SDPreferencesHideShowWhenSwitchingKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark -

- (void)dealloc {
    [_toggleApps release];
    [_preferencesWindow release];
    [_statItem release];
    
    [super dealloc];
}

@end
