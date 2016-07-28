//
//  PTKeyCombo.h
//  Protein
//
//  Created by Quentin Carnicelli on Sat Aug 02 2003.
//  Copyright (c) 2003 Quentin D. Carnicelli. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PTKeyCombo : NSObject <NSCopying>

@property (readonly) NSInteger keyCode;
@property (readonly) NSUInteger modifiers;

+ (id)clearKeyCombo;
+ (id)keyComboWithKeyCode: (NSInteger)keyCode modifiers: (NSUInteger)modifiers;
- (id)initWithKeyCode: (NSInteger)keyCode modifiers: (NSUInteger)modifiers;

- (id)initWithPlistRepresentation: (id)plist;
- (id)plistRepresentation;

- (BOOL)isEqual: (PTKeyCombo*)combo;

- (BOOL)isClearCombo;
- (BOOL)isValidHotKeyCombo;

@end


@interface PTKeyCombo (UserDisplayAdditions)
- (NSString*)keyCodeString;
- (NSUInteger)modifierMask;
@end
