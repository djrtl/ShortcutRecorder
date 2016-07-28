//
//  PTHotKey.m
//  Protein
//
//  Created by Quentin Carnicelli on Sat Aug 02 2003.
//  Copyright (c) 2003 Quentin D. Carnicelli. All rights reserved.
//

#import "PTHotKey.h"

#import "PTHotKeyCenter.h"
#import "PTKeyCombo.h"

@implementation PTHotKey

- (id)init
{
    return [self initWithIdentifier: nil keyCombo: nil withObject:nil];
}

- (id)initWithIdentifier: (id)identifier keyCombo: (PTKeyCombo*)combo
{
    return [self initWithIdentifier: identifier keyCombo: combo withObject:nil];

}

- (id)initWithIdentifier: (id)identifier keyCombo: (PTKeyCombo*)combo withObject: (id)object
{
    self = [super init];

    if( self )
    {
        [self setIdentifier: identifier];
        [self setKeyCombo: combo];
        [self setObject: object];
    }

    return self;
}


- (NSString*)description
{
    return [NSString stringWithFormat: @"<%@: %@, %@>", NSStringFromClass( [self class] ), [self identifier], [self keyCombo]];
}

#pragma mark -

- (void)setKeyCombo: (PTKeyCombo*)combo
{
    if( combo == nil )
        combo = [PTKeyCombo clearKeyCombo];

    _keyCombo = combo;
}

#pragma mark -

- (void)invoke
{
    if(self.action)
        [NSApp sendAction:self.action to:self.target from:self];
}

- (void)uninvoke
{
    if(self.keyUpAction)
        [NSApp sendAction:self.keyUpAction to:self.target from:self];
}

@end
