//
//  PreferencesWindowController.h
//  Solicitous Dock
//
//  Created by Charles Magahern on 12/17/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController<NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, retain) IBOutlet NSButton *hideShowCheckbox;
@property (nonatomic, retain) IBOutlet NSTableView *appsTableView;
@property (nonatomic, retain) IBOutlet NSButton *removeRowButton;

- (IBAction)hideShowCheckboxAction:(id)sender;
- (IBAction)addRowButtonAction:(id)sender;
- (IBAction)removeRowButtonAction:(id)sender;

@end
