//
//  PTHotKey.h
//  Protein
//
//  Created by Quentin Carnicelli on Sat Aug 02 2003.
//  Copyright (c) 2003 Quentin D. Carnicelli. All rights reserved.
//
//  Contributors:
// 		Andy Kim

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import "PTKeyCombo.h"

@interface PTHotKey : NSObject

@property (copy) NSString* identifier;
@property (copy) NSString* name;
@property (copy) PTKeyCombo* keyCombo;
@property (assign) id target;
@property (assign) id object;
@property (assign) SEL action;
@property (assign) SEL keyUpAction;
@property (assign) UInt32 carbonHotKeyID;
@property (assign) EventHotKeyRef carbonEventHotKeyRef;

- (id)initWithIdentifier: (id)identifier keyCombo: (PTKeyCombo*)combo;
- (id)initWithIdentifier: (id)identifier keyCombo: (PTKeyCombo*)combo withObject: (id)object;
- (id)init;

- (void)invoke;
- (void)uninvoke;

@end
