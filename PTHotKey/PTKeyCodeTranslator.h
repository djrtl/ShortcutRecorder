//
//  PTKeyCodeTranslator.h
//  Chercher
//
//  Created by Finlay Dobbie on Sat Oct 11 2003.
//  Copyright (c) 2003 Cliché Software. All rights reserved.
//

#import <Carbon/Carbon.h>

@interface PTKeyCodeTranslator : NSObject

+ (id)currentTranslator;

- (NSString *)translateKeyCode:(short)keyCode;

@end
