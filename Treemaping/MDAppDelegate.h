//
//  MDAppDelegate.h
//  Treemaping
//
//  Created by Malgorzata on 08/08/14.
//  Copyright (c) 2014 none. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MCTRTreemapView.h"

@interface MDAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic,strong)  MCTRTreemapView *treemapView;
@property (weak) IBOutlet NSPopUpButtonCell *listViewWithAlgorithms;
@property (weak) IBOutlet NSTextField *textFieldWithDataPath;

@end
