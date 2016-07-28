//
//  PTHotKeyCenter.h
//  Protein
//
//  Created by Quentin Carnicelli on Sat Aug 02 2003.
//  Copyright (c) 2003 Quentin D. Carnicelli. All rights reserved.
//
//  Contributors:
//      Quentin D. Carnicelli
//      Finlay Dobbie
//      Vincent Pottier
// 		Andy Kim

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@class PTHotKey;

@interface PTHotKeyCenter : NSObject

+ (PTHotKeyCenter *)sharedCenter;

- (BOOL)registerHotKey: (PTHotKey*)hotKey;
- (void)unregisterHotKey: (PTHotKey*)hotKey;

- (NSArray*)allHotKeys;
- (PTHotKey*)hotKeyWithIdentifier: (id)ident;

- (void)sendEvent: (NSEvent*)event;

- (void)pause;

- (void)resume;

- (BOOL)isPaused;

@end
