//
//  PreferencesWindowController.m
//  Solicitous Dock
//
//  Created by Charles Magahern on 12/17/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "Solicitous_DockAppDelegate.h"

@implementation PreferencesWindowController
{
  NSMutableArray *_activeApps;
  SDMenuIconStyle _currentIconStyle;
}

- (void)awakeFromNib { [super awakeFromNib];

  BOOL hideShowValue = [NSUSERDEFS boolForKey:SDPreferencesHideShowWhenSwitchingKey];
  [_hideShowCheckbox setState:hideShowValue];

  _activeApps = [(Solicitous_DockAppDelegate*)NSApplication.sharedApplication.delegate toggleApps];

  if ([_activeApps count] == 0) [_removeRowButton setEnabled:NO];

  [_iconStylePopUpButton selectItemAtIndex: _currentIconStyle = [NSUSERDEFS integerForKey:SDPreferencesIconStyleKey]];
  [self.window center];
}

- (void)saveChangesToFile {
  [NSUSERDEFS setInteger:_currentIconStyle forKey:SDPreferencesIconStyleKey];
  [NSUSERDEFS setObject:_activeApps forKey:SDPreferencesToggleAppsKey];
  [NSUSERDEFS synchronize];
}

- (IBAction)hideShowCheckboxAction:(id)sender {
  [NSUSERDEFS setBool:[_hideShowCheckbox state] forKey:SDPreferencesHideShowWhenSwitchingKey];
  [NSUSERDEFS synchronize];

  [_delegate preferencesDidChangeValue:@([_hideShowCheckbox state]) forKey:SDPreferencesHideShowWhenSwitchingKey];
}

- (IBAction)addRowButtonAction:(id)sender {  NSOpenPanel *filePanel = NSOpenPanel.openPanel;

  [filePanel setCanChooseFiles:YES];
  [filePanel setCanChooseDirectories:NO];

  [filePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
    if (result == NSOKButton) {

      NSURL        * selectedItem = filePanel.URLs[0];
      NSBundle        * appBundle = [NSBundle bundleWithURL:selectedItem];
      NSString * bundleIdentifier = appBundle.bundleIdentifier;
      NSString          * appName = [appBundle infoDictionary][@"CFBundleName"];

      NSDictionary *appEntry = @{ SDApplicationNameKey : appName, SDApplicationBundleIdentifierKey : bundleIdentifier };
      [_activeApps addObject:appEntry];

      [_appsTableView reloadData];
      [self saveChangesToFile];

      _removeRowButton.enabled = !_removeRowButton.isEnabled;
      [_delegate preferencesDidChangeValue:_activeApps forKey:SDPreferencesToggleAppsKey];
    }
  }];
}

- (IBAction)removeRowButtonAction:(id)sender {

  [_activeApps removeObjectsAtIndexes:_appsTableView.selectedRowIndexes];
  [_appsTableView reloadData];
  [self saveChangesToFile];
  _removeRowButton.enabled = !_activeApps.count;
  [_delegate preferencesDidChangeValue:_activeApps forKey:SDPreferencesToggleAppsKey];
}

- (IBAction)menuIconStyleChangedAction:(id)sender {

  _currentIconStyle = _iconStylePopUpButton.indexOfSelectedItem;
  [self saveChangesToFile];
  [_delegate preferencesDidChangeValue:@(_currentIconStyle) forKey:SDPreferencesIconStyleKey];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
  return _activeApps[rowIndex][SDApplicationNameKey];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView { return _activeApps.count; }

@end
