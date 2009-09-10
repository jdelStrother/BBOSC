//
//  BBOSCManager.m
//  BBOSC
//
//  Created by Jonathan del Strother on 10/09/2009.
//  Copyright 2009 Best Before Media Ltd. All rights reserved.
//

#import "BBOSCManager.h"
#import "OSCExtensions.h"


@implementation BBOSCManager

static id sharedManager=nil;
+(id)sharedManager {
	if (!sharedManager)
		sharedManager = [[self alloc] init];
	return sharedManager;
}
-(id)init {
	if (self = [super init]) {
		oscManager = [[OSCManager alloc] init];
		oscManager.delegate = self;
		delegates = [[NSMutableArray alloc] init];
		delegateLock = [[NSLock alloc] init];
	}
	return self;
}

-(void)addDelegate:(id)delegate {
	[delegateLock lock];
	[delegates addObject:delegate];
	[delegateLock unlock];
}
-(void)removeDelegate:(id)delegate {
	[delegateLock lock];
	[delegates removeObject:delegate];
	[delegateLock unlock];
}

- (void) receivedOSCMessage:(OSCMessage *)m {
	[delegateLock lock];
	[delegates makeObjectsPerformSelector:@selector(receivedOSCMessage:) withObject:m];
	[delegateLock unlock];
}

- (OSCInPort *) createNewInputForPort:(int)p withLabel:(NSString *)l {
	return [oscManager createNewInputForPort:p withLabel:l];
}
- (OSCOutPort *) createNewOutputToAddress:(NSString *)a atPort:(int)p withLabel:(NSString *)l {
	return [oscManager createNewOutputToAddress:a atPort:p withLabel:l];
}
- (void) removeInput:(id)p {
	[oscManager removeInput:p];
}
- (void) removeOutput:(id)p {
	[oscManager removeOutput:p];
}

@end
