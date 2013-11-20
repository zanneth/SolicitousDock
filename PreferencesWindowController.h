//
//  PreferencesWindowController.h
//  Solicitous Dock
//
//  Created by Charles Magahern on 12/17/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PreferencesWindowDelegate <NSObject>
@required
- (void)preferencesDidChangeValue:(id)value forKey:(NSString *)key;
@end
   
@interface PreferencesWindowController : NSWindowController<NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, assign) id<PreferencesWindowDelegate> delegate;
@property (nonatomic, retain) IBOutlet NSButton *hideShowCheckbox;
@property (nonatomic, retain) IBOutlet NSTableView *appsTableView;
@property (nonatomic, retain) IBOutlet NSButton *removeRowButton;
@property (nonatomic, retain) IBOutlet NSPopUpButton *iconStylePopUpButton;

- (IBAction)hideShowCheckboxAction:(id)sender;
- (IBAction)addRowButtonAction:(id)sender;
- (IBAction)removeRowButtonAction:(id)sender;
- (IBAction)menuIconStyleChangedAction:(id)sender;

@end
