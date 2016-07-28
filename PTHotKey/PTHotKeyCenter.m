//
//  PTHotKeyCenter.m
//  Protein
//
//  Created by Quentin Carnicelli on Sat Aug 02 2003.
//  Copyright (c) 2003 Quentin D. Carnicelli. All rights reserved.
//

#import "PTHotKeyCenter.h"
#import "PTHotKey.h"
#import "PTKeyCombo.h"

@interface PTHotKeyCenter ()

// Keys are carbon hot key IDs
@property (strong) NSMutableDictionary* hotKeys;
@property (assign) UInt32 nextHotKeyId;
@property (assign, getter=isPaused) BOOL paused;
@property (assign) EventHandlerRef eventHandler;
@property (assign, getter=isEventHandlerInstalled) BOOL eventHandlerInstalled;

- (PTHotKey*)_hotKeyForCarbonHotKey: (EventHotKeyRef)carbonHotKey;
- (PTHotKey*)_hotKeyForCarbonHotKeyID: (EventHotKeyID)hotKeyID;

- (void)_updateEventHandler;
- (void)_hotKeyDown: (PTHotKey*)hotKey;
- (void)_hotKeyUp: (PTHotKey*)hotKey;
static OSStatus hotKeyEventHandler(EventHandlerCallRef inHandlerRef, EventRef inEvent, void* refCon );
@end

@implementation PTHotKeyCenter

+ (PTHotKeyCenter*)sharedCenter
{
    static PTHotKeyCenter* _sharedHotKeyCenter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHotKeyCenter = [[self alloc] init];
    });

	return _sharedHotKeyCenter;
}

- (id)init
{
	self = [super init];

	if( self )
	{
		_hotKeys = [[NSMutableDictionary alloc] init];
	}

	return self;
}


#pragma mark -

- (BOOL)registerHotKey: (PTHotKey*)hotKey
{
    if (![self isPaused])
    {
        OSStatus err;
        EventHotKeyID hotKeyID;
        EventHotKeyRef carbonHotKey;

        if( [[self allHotKeys] containsObject: hotKey] == YES )
            [self unregisterHotKey: hotKey];

        if( [[hotKey keyCombo] isValidHotKeyCombo] == NO )
            return YES;

        hotKeyID.signature = 'PTHk';
        hotKeyID.id = ++self.nextHotKeyId;

        err = RegisterEventHotKey(  (SInt32)[[hotKey keyCombo] keyCode],
                                    (UInt32)[[hotKey keyCombo] modifiers],
                                    hotKeyID,
                                    GetEventDispatcherTarget(),
                                    0,
                                    &carbonHotKey );

        if( err )
            return NO;

        [hotKey setCarbonHotKeyID:hotKeyID.id];
        [hotKey setCarbonEventHotKeyRef:carbonHotKey];

        if( hotKey )
            [self.hotKeys setObject: hotKey forKey: [NSNumber numberWithInteger:hotKeyID.id]];

        [self _updateEventHandler];
    }
    else
    {
        EventHotKeyID hotKeyID = {'PTHk', ++self.nextHotKeyId};
        [hotKey setCarbonHotKeyID:hotKeyID.id];

        if( hotKey )
            [self.hotKeys setObject: hotKey forKey: [NSNumber numberWithInteger:hotKeyID.id]];
    }
    return YES;
}

- (void)unregisterHotKey: (PTHotKey*)hotKey
{
    if (![self isPaused] )
    {
        EventHotKeyRef carbonHotKey;

        if( [[self allHotKeys] containsObject: hotKey] == NO )
            return;

        carbonHotKey = [hotKey carbonEventHotKeyRef];

        if( carbonHotKey )
        {
            UnregisterEventHotKey( carbonHotKey );
            //Watch as we ignore 'err':

            [self.hotKeys removeObjectForKey: [NSNumber numberWithInteger:[hotKey carbonHotKeyID]]];

            [hotKey setCarbonHotKeyID:0];
            [hotKey setCarbonEventHotKeyRef:NULL];

            [self _updateEventHandler];

            //See that? Completely ignored
        }
    }
    else
    {
        [self.hotKeys removeObjectForKey: [NSNumber numberWithInteger:[hotKey carbonHotKeyID]]];

        [hotKey setCarbonHotKeyID:0];
        [hotKey setCarbonEventHotKeyRef:NULL];
    }
}

- (NSArray*)allHotKeys
{
	return [self.hotKeys allValues];
}

- (PTHotKey*)hotKeyWithIdentifier: (id)ident
{
	NSEnumerator* hotKeysEnum = [[self allHotKeys] objectEnumerator];
	PTHotKey* hotKey;

	if( !ident )
		return nil;

	while( (hotKey = [hotKeysEnum nextObject]) != nil )
	{
		if( [[hotKey identifier] isEqual: ident] )
			return hotKey;
	}

	return nil;
}

#pragma mark -

- (PTHotKey*)_hotKeyForCarbonHotKey: (EventHotKeyRef)carbonHotKeyRef
{
	NSEnumerator *e = [self.hotKeys objectEnumerator];
	PTHotKey *hotkey = nil;

	while( (hotkey = [e nextObject]) )
	{
		if( [hotkey carbonEventHotKeyRef] == carbonHotKeyRef )
			return hotkey;
	}

	return nil;
}

- (PTHotKey*)_hotKeyForCarbonHotKeyID: (EventHotKeyID)hotKeyID
{
	return [self.hotKeys objectForKey:[NSNumber numberWithInteger:hotKeyID.id]];
}

- (void)_updateEventHandler
{
	if( [self.hotKeys count] && ![self isEventHandlerInstalled] )
	{
		EventTypeSpec eventSpec[2] = {
			{ kEventClassKeyboard, kEventHotKeyPressed },
			{ kEventClassKeyboard, kEventHotKeyReleased }
		};

        EventHandlerRef eventHandler = self.eventHandler;
		InstallEventHandler( GetEventDispatcherTarget(),
							 (EventHandlerProcPtr)hotKeyEventHandler,
							 2, eventSpec, nil, &eventHandler);

		self.eventHandlerInstalled = YES;
	}
}

- (void)_hotKeyDown: (PTHotKey*)hotKey
{
	[hotKey invoke];
}

- (void)_hotKeyUp: (PTHotKey*)hotKey
{
    [hotKey uninvoke];
}

- (void)sendEvent: (NSEvent*)event
{
	// Not sure why this is needed? - Andy Kim (Aug 23, 2009)

	short subType;
	EventHotKeyRef carbonHotKey;

	if( [event type] == NSSystemDefined )
	{
		subType = [event subtype];

		if( subType == 6 ) //6 is hot key down
		{
			carbonHotKey= (EventHotKeyRef)[event data1]; //data1 is our hot key ref
			if( carbonHotKey != nil )
			{
				PTHotKey* hotKey = [self _hotKeyForCarbonHotKey: carbonHotKey];
				[self _hotKeyDown: hotKey];
			}
		}
		else if( subType == 9 ) //9 is hot key up
		{
			carbonHotKey= (EventHotKeyRef)[event data1];
			if( carbonHotKey != nil )
			{
				PTHotKey* hotKey = [self _hotKeyForCarbonHotKey: carbonHotKey];
				[self _hotKeyUp: hotKey];
			}
		}
	}
}

- (OSStatus)sendCarbonEvent: (EventRef)event
{
	OSStatus err;
	EventHotKeyID hotKeyID;
	PTHotKey* hotKey;

	NSAssert( GetEventClass( event ) == kEventClassKeyboard, @"Unknown event class" );

	err = GetEventParameter(	event,
								kEventParamDirectObject,
								typeEventHotKeyID,
								nil,
								sizeof(EventHotKeyID),
								nil,
								&hotKeyID );
	if( err )
		return err;

    	if( hotKeyID.signature != 'PTHk' )
        	return eventNotHandledErr;

    if (hotKeyID.id == 0)
        return eventNotHandledErr;

	hotKey = [self _hotKeyForCarbonHotKeyID:hotKeyID];

	switch( GetEventKind( event ) )
	{
		case kEventHotKeyPressed:
			[self _hotKeyDown: hotKey];
		break;

		case kEventHotKeyReleased:
			[self _hotKeyUp: hotKey];
		break;

		default:
			return eventNotHandledErr;
		break;
	}

	return noErr;
}

- (void)pause
{
    if ([self isPaused])
        return;

    self.paused = YES;
    for (NSNumber *hotKeyID in self.hotKeys)
    {
        PTHotKey *hotKey = [self.hotKeys objectForKey:hotKeyID];
        EventHotKeyRef carbonHotKey = [hotKey carbonEventHotKeyRef];
        UnregisterEventHotKey( carbonHotKey );
        [hotKey setCarbonEventHotKeyRef:NULL];
    }
    if (self.eventHandler != NULL)
    {
        RemoveEventHandler(self.eventHandler);
        self.eventHandler = NULL;
        self.eventHandlerInstalled = NO;
    }
}

- (void)resume
{
    if (![self isPaused])
        return;

    self.paused = NO;
    for (NSNumber *hotKeyIDNumber in self.hotKeys)
    {
        PTHotKey *hotKey = [self.hotKeys objectForKey:hotKeyIDNumber];
        EventHotKeyRef carbonHotKey = NULL;
        EventHotKeyID hotKeyID;
        hotKeyID.signature = 'PTHk';
        hotKeyID.id = [hotKey carbonHotKeyID];
        RegisterEventHotKey(  (SInt32)[[hotKey keyCombo] keyCode],
                              (UInt32)[[hotKey keyCombo] modifiers],
                              hotKeyID,
                              GetEventDispatcherTarget(),
                              0,
                              &carbonHotKey );
        [hotKey setCarbonEventHotKeyRef:carbonHotKey];
    }
    [self _updateEventHandler];
}

static OSStatus hotKeyEventHandler(EventHandlerCallRef inHandlerRef, EventRef inEvent, void* refCon )
{
    return [[PTHotKeyCenter sharedCenter] sendCarbonEvent: inEvent];
}

@end
