//
//  Solicitous_DockAppDelegate.m
//  Solicitous Dock
//
//  Created by Charles Magahern on 12/16/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "Solicitous_DockAppDelegate.h"
#import <ApplicationServices/ApplicationServices.h>
#import <objc/message.h>


int main(int argc, char *argv[]) { return NSApplicationMain(argc,  (const char **) argv); }

NSString  * const SDPreferencesHideShowWhenSwitchingKey = @"SDPreferencesHideShowWhenSwitchingKey",
          * const SDApplicationBundleIdentifierKey      = @"SDApplicationBundleIdentifierKey",
          * const SDPreferencesDefaultsExistKey         = @"SDPreferencesDefaultsExistKey",
          * const SDPreferencesToggleAppsKey            = @"SDPreferencesToggleAppsKey",
          * const SDPreferencesIconStyleKey             = @"SDPreferencesIconStyleKey",
          * const SDApplicationNameKey                  = @"SDApplicationNameKey";

// private functions in ApplicationServices that alter dock autohide state
extern  Boolean CoreDockGetAutoHideEnabled();
extern OSStatus CoreDockSetAutoHideEnabled(Boolean);

@implementation Solicitous_DockAppDelegate { NSStatusItem *_statItem; }

@synthesize dockHidden = _dockHidden, toggleAppsOpenCount = _toggleAppsOpenCount,
            toggleApps = _toggleApps, preferencesWindow   = _preferencesWindow;

#pragma mark - Menu Actions

- (void)aboutAction:(id)sender {

  [NSApplication.sharedApplication orderFrontStandardAboutPanel:sender];
  [NSApplication.sharedApplication activateIgnoringOtherApps:YES];
}

- (void)preferencesAction:(id)sender {

  if (!_preferencesWindow)
    [_preferencesWindow = [PreferencesWindowController.alloc initWithWindowNibName:@"PreferencesWindowController"] setDelegate:self];

  [_preferencesWindow.window makeKeyAndOrderFront:self];
  [NSApplication.sharedApplication activateIgnoringOtherApps:YES];
}

- (void)quitAction:(id)sender { [NSApplication.sharedApplication terminate:sender]; }

- (void)debug_toggleAction:(id)sender { [self toggleShowDock]; }

#pragma mark - Helper Methods

- (void)toggleShowDock {  _dockHidden = !_dockHidden;  CoreDockSetAutoHideEnabled(_dockHidden); }

- (BOOL)applicationBundleIdentifierIsAToggle:(NSString *)bundleIdentifier {

  return [[_toggleApps valueForKey:SDApplicationBundleIdentifierKey] containsObject:bundleIdentifier];
}

- (void)addWorkspaceObservers {

  [@{ @"workspaceApplicationDidLaunch:"       : NSWorkspaceWillLaunchApplicationNotification,
      @"workspaceApplicationDidQuit:"         : NSWorkspaceDidTerminateApplicationNotification,
      @"workspaceApplicationDidBecomeActive:" : NSWorkspaceDidActivateApplicationNotification } enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self selector:NSSelectorFromString(key)
                                                               name:obj    object:nil];
      }];
}
- (NSString *)_menuIconImageNameForIconStyle:(SDMenuIconStyle)iconStyle {

  static NSString *const baseName = @"menu-icon", *const blackAndWhiteStyle = @"gray", *const colorStyle = @"color";

  NSString *styleName = iconStyle == SDMenuIconStyleColor         ? colorStyle :
                        iconStyle == SDMenuIconStyleBlackAndWhite ? blackAndWhiteStyle : nil;

  return [NSString stringWithFormat:@"%@_%@", baseName, styleName];
}

- (void)_updateStatItemIconImage {

  if (!_statItem) {
    _statItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [_statItem setToolTip:@"Solicitous Dock"];
    [_statItem setHighlightMode:YES];
  }

  SDMenuIconStyle currentIconStyle = [NSUSERDEFS integerForKey:SDPreferencesIconStyleKey];
  [_statItem setImage:[NSImage imageNamed:[self _menuIconImageNameForIconStyle:currentIconStyle]]];
}

- (void)addStatusBarItems {
  [self _updateStatItemIconImage];

  NSMenu *menu = [NSMenu allocWithZone:[NSMenu menuZone]].init;
  NSMenuItem *aboutItem = [menu addItemWithTitle:@"About Solicitous Dock" action:@selector(aboutAction:) keyEquivalent:@""];
  [menu addItem:NSMenuItem.separatorItem];
  NSMenuItem *preferencesItem = [menu addItemWithTitle:@"Preferences..." action:@selector(preferencesAction:) keyEquivalent:@""];
  NSMenuItem *quitItem = [menu addItemWithTitle:@"Quit" action:@selector(quitAction:) keyEquivalent:@""];

  aboutItem.target = preferencesItem.target = quitItem.target = self;

#ifdef DEBUG_ENABLED
  NSMenuItem *toggleItem = [menu addItemWithTitle:@"DEBUG_ToggleShow" action:@selector(debug_toggleAction:) keyEquivalent:@""];
  [toggleItem setTarget:self];
#endif

  [_statItem setMenu:menu];
}

#pragma mark - Workspace Notification Delegate Methods

- (void)workspaceApplicationDidLaunch:(id)sender {

  NSString *identifier = ((NSNotification*)sender).userInfo[@"NSApplicationBundleIdentifier"];

  if (![self applicationBundleIdentifierIsAToggle:identifier]) return;
  if (!_dockHidden)[self toggleShowDock];
  _toggleAppsOpenCount++;
}

- (void)workspaceApplicationDidQuit:(id)sender {

  NSString *identifier = (((NSNotification*)sender).userInfo)[@"NSApplicationBundleIdentifier"];

  if ([self applicationBundleIdentifierIsAToggle:identifier]) _toggleAppsOpenCount--;

  if (![NSUSERDEFS boolForKey:SDPreferencesHideShowWhenSwitchingKey] &&
      [self applicationBundleIdentifierIsAToggle:identifier] && _dockHidden && _toggleAppsOpenCount == 0)
    [self toggleShowDock];
}

- (void)workspaceApplicationDidBecomeActive:(id)sender {

  if (![NSUSERDEFS boolForKey:SDPreferencesHideShowWhenSwitchingKey]) return;

  NSString *identifier = [((NSNotification*)sender).userInfo[@"NSWorkspaceApplicationKey"] bundleIdentifier];

  [self applicationBundleIdentifierIsAToggle:identifier] && !_dockHidden ? [self toggleShowDock] :
  _dockHidden ? [self toggleShowDock] : nil;
}

#pragma mark - Initializer

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  NSArray *settings = [NSUSERDEFS objectForKey:SDPreferencesToggleAppsKey];

  _toggleApps          = settings ? settings.mutableCopy : @[].mutableCopy;
  _dockHidden          = CoreDockGetAutoHideEnabled();
  _toggleAppsOpenCount = 0;

  [NSWorkspace.sharedWorkspace.runningApplications enumerateObjectsUsingBlock:^(NSRunningApplication *app, NSUInteger idx, BOOL *stop) {
    if ([self applicationBundleIdentifierIsAToggle:[app bundleIdentifier]])
      _toggleAppsOpenCount++;
  }];

  [self addWorkspaceObservers];  [self addStatusBarItems];

  if ([NSUSERDEFS boolForKey:SDPreferencesDefaultsExistKey]) return;

  [@{ SDPreferencesToggleAppsKey            : _toggleApps,
      SDPreferencesDefaultsExistKey         : @YES,
      SDPreferencesHideShowWhenSwitchingKey : @YES} enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        objc_msgSend( NSUSERDEFS,
                     NSSelectorFromString([obj isKindOfClass:NSNumber.class] ? @"setBool:forKey:" : @"setObject:forKey:"),
                     obj,key);
      }];
}

#pragma mark - Preferences Window callback methods

- (void)preferencesDidChangeValue:(id)value forKey:(NSString *)key {

  if ([key isEqualToString:SDPreferencesIconStyleKey]) [self _updateStatItemIconImage];
}

@end
