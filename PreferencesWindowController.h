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

@property (nonatomic) IBOutlet      NSButton * hideShowCheckbox;
@property (nonatomic) IBOutlet   NSTableView * appsTableView;
@property (nonatomic) IBOutlet      NSButton * removeRowButton;
@property (nonatomic) IBOutlet NSPopUpButton * iconStylePopUpButton;
@property (nonatomic, unsafe_unretained)  id   <PreferencesWindowDelegate>
                                               delegate;

- (IBAction) hideShowCheckboxAction:    (id)sender;
- (IBAction) addRowButtonAction:        (id)sender;
- (IBAction) removeRowButtonAction:     (id)sender;
- (IBAction) menuIconStyleChangedAction:(id)sender;

@end
