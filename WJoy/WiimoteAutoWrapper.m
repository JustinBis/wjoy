//
//  WiimoteAutoWrapper.m
//  WJoy
//
//  Created by alxn1 on 27.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteAutoWrapper.h"
#import "UserActivityNotifier.h"

#import <Cocoa/Cocoa.h>

@interface WiimoteAutoWrapper (PrivatePart)

+ (NSString*)wjoyNameFromWiimote:(Wiimote*)device;

+ (void)newWiimoteDeviceNotification:(NSNotification*)notification;

- (id)initWithWiimote:(Wiimote*)device;

@end

@implementation WiimoteAutoWrapper

static NSUInteger maxConnectedDevices = 0;

+ (NSUInteger)maxConnectedDevices
{
    return maxConnectedDevices;
}

+ (void)setMaxConnectedDevices:(NSUInteger)count
{
    if(maxConnectedDevices == count)
        return;

    maxConnectedDevices = count;

    while([[Wiimote connectedDevices] count] > count)
    {
        NSArray  *connectedDevices   = [Wiimote connectedDevices];
        Wiimote  *device             = [connectedDevices objectAtIndex:[connectedDevices count] - 1];

        [device disconnect];
    }
}

+ (void)start
{
    if(![WJoyDevice prepare])
    {
        [[NSApplication sharedApplication] terminate:self];
        return;
    }

    [[NSNotificationCenter defaultCenter]
                            addObserver:self
                               selector:@selector(newWiimoteDeviceNotification:)
                                   name:WiimoteConnectedNotification
                                 object:nil];
}

- (void)wiimote:(Wiimote*)wiimote buttonPressed:(WiimoteButtonType)button
{
    [m_HIDState setButton:button pressed:YES];
}

- (void)wiimote:(Wiimote*)wiimote buttonReleased:(WiimoteButtonType)button
{
    [m_HIDState setButton:button pressed:NO];
}

- (void)wiimoteDisconnected:(Wiimote*)wiimote
{
    [self release];
}

- (void)wiimote:(Wiimote*)wiimote nunchuck:(WiimoteNunchuckExtension*)nunchuck buttonPressed:(WiimoteNunchuckButtonType)button
{
    [m_HIDState setButton:WiimoteButtonCount + button pressed:YES];
}

- (void)wiimote:(Wiimote*)wiimote nunchuck:(WiimoteNunchuckExtension*)nunchuck buttonReleased:(WiimoteNunchuckButtonType)button
{
    [m_HIDState setButton:WiimoteButtonCount + button pressed:NO];
}

- (void)wiimote:(Wiimote*)wiimote nunchuck:(WiimoteNunchuckExtension*)nunchuck stickPositionChanged:(NSPoint)position
{
    [m_HIDState setPointer:0 position:position];
}

- (void)      wiimote:(Wiimote*)wiimote
    classicController:(WiimoteClassicControllerExtension*)classic
        buttonPressed:(WiimoteClassicControllerButtonType)button
{
    [m_HIDState setButton:WiimoteButtonCount + button pressed:YES];
}

- (void)      wiimote:(Wiimote*)wiimote
    classicController:(WiimoteClassicControllerExtension*)classic
       buttonReleased:(WiimoteClassicControllerButtonType)button
{
    [m_HIDState setButton:WiimoteButtonCount + button pressed:NO];
}

- (void)      wiimote:(Wiimote*)wiimote
    classicController:(WiimoteClassicControllerExtension*)classic
                stick:(WiimoteClassicControllerStickType)stick
      positionChanged:(NSPoint)position
{
    [m_HIDState setPointer:stick position:position];
}

- (void)      wiimote:(Wiimote*)wiimote
    classicController:(WiimoteClassicControllerExtension*)classic
          analogShift:(WiimoteClassicControllerAnalogShiftType)shift
      positionChanged:(CGFloat)position
{
	switch(shift)
	{
		case WiimoteClassicControllerAnalogShiftTypeLeft:
			m_ShiftsState.x = position;
			break;

		case WiimoteClassicControllerAnalogShiftTypeRight:
			m_ShiftsState.y = position;
			break;
	}

	[m_HIDState setPointer:WiimoteClassicControllerStickCount position:m_ShiftsState];
}

- (void)      wiimote:(Wiimote*)wiimote
	   uProController:(WiimoteUProControllerExtension*)uPro
        buttonPressed:(WiimoteUProControllerButtonType)button
{
	[m_HIDState setButton:WiimoteButtonCount + button pressed:YES];
}

- (void)      wiimote:(Wiimote*)wiimote
	   uProController:(WiimoteUProControllerExtension*)uPro
       buttonReleased:(WiimoteUProControllerButtonType)button
{
	[m_HIDState setButton:WiimoteButtonCount + button pressed:NO];
}

- (void)      wiimote:(Wiimote*)wiimote
	   uProController:(WiimoteUProControllerExtension*)uPro
                stick:(WiimoteUProControllerStickType)stick
      positionChanged:(NSPoint)position
{
	// Calibrate the analog sticks on the fly
	// Thanks to Kametrixom for the fix ( https://github.com/Kametrixom/wjoy-1/commit/686c49a5de411ba77f459ba1325b17ba1b44c343 )
	switch (stick) {
		case WiimoteUProControllerStickTypeLeft:
			minL.x = MIN(minL.x, position.x);
			minL.y = MIN(minL.y, position.y);
			
			maxL.x = MAX(maxL.x, position.x);
			maxL.y = MAX(maxL.y, position.y);
			
			position.x = (position.x - minL.x) / (maxL.x - minL.x) * 2 - 1;
			position.y = (position.y - minL.y) / (maxL.y - minL.y) * 2 - 1;
			break;
		case WiimoteUProControllerStickTypeRight:
			minR.x = MIN(minR.x, position.x);
			minR.y = MIN(minR.y, position.y);
			
			maxR.x = MAX(maxR.x, position.x);
			maxR.y = MAX(maxR.y, position.y);
			
			position.x = (position.x - minR.x) / (maxR.x - minR.x) * 2 - 1;
			position.y = (position.y - minR.y) / (maxR.y - minR.y) * 2 - 1;
			break;
	}
	
	NSLog(@"\nMinLx: %i\tMinLy: %i\tMaxLx: %i\tMaxLy: %i", minL.x, minL.y, maxL.x, maxL.y);
	NSLog(@"\nMinRx: %i\tMinRy: %i\tMaxRx: %i\tMaxRy: %i", minR.x, minR.y, maxR.x, maxR.y);
	
	[m_HIDState setPointer:stick position:position];
}

- (void)wiimote:(Wiimote*)wiimote extensionDisconnected:(WiimoteExtension*)extension
{
	m_ShiftsState = NSZeroPoint;

	for(NSUInteger i = 0; i <= WiimoteClassicControllerStickCount; i++)
		[m_HIDState setPointer:0 position:NSZeroPoint];

	for(NSUInteger i = 0; i < WiimoteClassicControllerButtonCount; i++)
		[m_HIDState setButton:WiimoteButtonCount + i pressed:NO];
}

- (void)VHIDDevice:(VHIDDevice*)device stateChanged:(NSData*)state
{
    [[UserActivityNotifier sharedNotifier] notify];
    [m_WJoy updateHIDState:state];
}

- (void)applicationWillTerminateNotification:(NSNotification*)notification
{
    [m_Device disconnect];
}

@end

@implementation WiimoteAutoWrapper (PrivatePart)

+ (NSString*)wjoyNameFromWiimote:(Wiimote*)device
{
    return [NSString stringWithFormat:@"Wiimote (%@)", [device addressString]];
}

+ (void)newWiimoteDeviceNotification:(NSNotification*)notification
{
    [[WiimoteAutoWrapper alloc]
        initWithWiimote:(Wiimote*)[notification object]];
}

- (id)init
{
    [[super init] release];
    return nil;
}

- (id)initWithWiimote:(Wiimote*)device
{
    self = [super init];
    if(self == nil)
        return nil;

    if([[Wiimote connectedDevices] count] > [WiimoteAutoWrapper maxConnectedDevices])
    {
        [device disconnect];
        [self release];
        return nil;
    }

    m_Device    = device;
    m_HIDState  = [[VHIDDevice alloc] initWithType:VHIDDeviceTypeJoystick
                                      pointerCount:WiimoteClassicControllerStickCount + 1
                                       buttonCount:WiimoteButtonCount + WiimoteClassicControllerButtonCount
                                        isRelative:NO];

    m_WJoy      = [[WJoyDevice alloc]
                             initWithHIDDescriptor:[m_HIDState descriptor]
                                     productString:[WiimoteAutoWrapper wjoyNameFromWiimote:device]];

    if(m_HIDState   == nil ||
       m_WJoy       == nil)
    {
        [device disconnect];
        [self release];
        return nil;
    }

    [m_Device setDelegate:self];
    [m_HIDState setDelegate:self];

    [[NSNotificationCenter defaultCenter]
                                    addObserver:self
                                       selector:@selector(applicationWillTerminateNotification:)
                                           name:NSApplicationWillTerminateNotification
                                         object:[NSApplication sharedApplication]];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [m_HIDState release];
    [m_WJoy release];
    [super dealloc];
}

@end
