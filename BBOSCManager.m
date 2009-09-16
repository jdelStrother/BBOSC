//
//  BBOSCManager.m
//  BBOSC
//
//  Created by Jonathan del Strother on 10/09/2009.
//  Copyright 2009 Best Before Media Ltd. All rights reserved.
//

#import "BBOSCManager.h"
#import "OSCExtensions.h"
#import "NSArrayExtensions.h"
#import "BBOSCInPort.h"

@interface BBOSCBroadcastPort : NSObject {
	OSCManager* oscManager;
	int portNumber;
	OSCOutPort* localPort;
}
-(id)initWithManager:(OSCManager*)manager atPort:(int)p;
@end
@implementation BBOSCBroadcastPort
-(id)initWithManager:(OSCManager*)manager atPort:(int)p {
	if (self = [super init]) {
		oscManager = manager;
		portNumber = p;
		// Make sure that the OSC Manager knows we can broadcast to ourselves
		localPort = [[oscManager createNewOutputToAddress:@"127.0.0.1" atPort:p] retain];
	}
	return self;
}
-(void)dealloc {
	[oscManager removeOutput:localPort];
	[localPort release];
	[super dealloc];
}
-(void)sendThisMessage:(OSCMessage*)message {
	// Broadcast to all discovered outPorts with the same port number as us.
	[[oscManager outPortArray] rdlock];
	NSArray* suitablePorts = [[[oscManager outPortArray] array] select:^BOOL(OSCOutPort* oscPort){return (oscPort.port == portNumber);}];
	[[oscManager outPortArray] unlock];
	[suitablePorts makeObjectsPerformSelector:@selector(sendThisMessage:) withObject:message];

}
@end

@implementation BBOSCManager

static id sharedManager=nil;
+(BBOSCManager*)sharedManager {
	if (!sharedManager)
		sharedManager = [[self alloc] init];
	return sharedManager;
}
-(id)init {
	if (self = [super init]) {
		oscManager = [[OSCManager alloc] init];
		oscManager.delegate = self;
		inputPorts = [[NSCountedSet alloc] init];
	}
	return self;
}

- (BBOSCInPort *) createNewInputForPort:(int)p withLabel:(NSString *)l {
	// Search for any existing oscPorts with the same port number, and re-use them when possible
	BBOSCInPort* resultingPort = nil;
	for(BBOSCInPort* oscPort in inputPorts) {
		if (oscPort.port == p) {
			NSAssert([oscPort.portLabel isEqualToString:l], @"Need to be using the same label");
			resultingPort = oscPort;
			break;
		}
	}
	if (!resultingPort) {
		resultingPort = [[[BBOSCInPort alloc] initWithManager:oscManager withPort:p label:l] autorelease];
	}

	// This is a counted set, so we always add the port, so we can keep track of how many people are using it.
	[inputPorts addObject:resultingPort];
	
	return resultingPort;
}
- (OSCOutPort *) createNewOutputToAddress:(NSString *)a atPort:(int)p withLabel:(NSString *)l {
	if ([a isEqualToString:@"0.0.0.0"])	// Broadcast to everyone
		return [[[BBOSCBroadcastPort alloc] initWithManager:oscManager atPort:p] autorelease];
	return [oscManager createNewOutputToAddress:a atPort:p withLabel:l];
}
- (void) removeInput:(BBOSCInPort*)p {
	[inputPorts removeObject:p];
	// Once noone is using that input any more, remove it from the oscManager.
	if ([inputPorts countForObject:p] == 0)
		[p remove];
}
- (void) removeOutput:(OSCOutPort*)p {
	[oscManager removeOutput:p];
}

@end
