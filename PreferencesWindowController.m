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
@synthesize hideShowCheckbox, appsTableView, removeRowButton;
NSMutableArray *activeApps;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    BOOL hideShowValue = [[NSUserDefaults standardUserDefaults] boolForKey:@"HideShowWhenSwitching"];
    [hideShowCheckbox setState:hideShowValue];
    
    Solicitous_DockAppDelegate *del = (Solicitous_DockAppDelegate *) [[NSApplication sharedApplication] delegate];
    activeApps = [del toggleApps];
    
    if ([activeApps count] == 0)
        [removeRowButton setEnabled:NO];
    
    [[self window] center];
}

- (void)saveChangesToFile {
    [[NSUserDefaults standardUserDefaults] setObject:activeApps forKey:@"ToggleApps"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void  *)contextInfo {
    if (returnCode == NSOKButton) {
        NSArray *selectedItems = [panel URLs];
        NSURL *selectedItem = [selectedItems objectAtIndex:0];
        
        NSBundle *appBundle = [NSBundle bundleWithURL:selectedItem];
        NSString *bundleIdentifier = [appBundle bundleIdentifier];
        NSString *appName = [[appBundle infoDictionary] objectForKey:@"CFBundleName"];
        
        [activeApps addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:appName, bundleIdentifier, nil]
                                                          forKeys:[NSArray arrayWithObjects:@"Application Name", @"Bundle Identifier", nil]]];
        [appsTableView reloadData];
        [self saveChangesToFile];
        
        if (![removeRowButton isEnabled])
            [removeRowButton setEnabled:YES];
    }
}

- (IBAction)hideShowCheckboxAction:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[hideShowCheckbox state] forKey:@"HideShowWhenSwitching"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)addRowButtonAction:(id)sender {
    NSOpenPanel *filePanel = [NSOpenPanel openPanel];
    [filePanel setCanChooseFiles:YES];
    [filePanel setCanChooseDirectories:NO];
    
    [filePanel beginSheetForDirectory:nil
                                 file:nil
                                types:[NSArray arrayWithObject:@"app"]
                       modalForWindow:[self window]
                        modalDelegate:self
                       didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
                          contextInfo:NULL];
}

- (IBAction)removeRowButtonAction:(id)sender {
    NSIndexSet *selected = [appsTableView selectedRowIndexes];
    [activeApps removeObjectsAtIndexes:selected];
    [appsTableView reloadData];
    
    [self saveChangesToFile];
    
    if ([activeApps count] == 0)
        [removeRowButton setEnabled:NO];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return [[activeApps objectAtIndex:rowIndex] objectForKey:@"Application Name"];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [activeApps count];
}

- (void)dealloc {
    
    [super dealloc];
}

@end
