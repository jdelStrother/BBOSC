//
//  BBOSCInPort.m
//  BBOSC
//
//  Created by Jonathan del Strother on 16/09/2009.
//  Copyright 2009 Best Before Media Ltd. All rights reserved.
//

#import "BBOSCInPort.h"
#import "OSCExtensions.h"

@implementation BBOSCInPort
-(id)initWithManager:(OSCManager*)manager withPort:(unsigned int)p label:(NSString*)l {
	if (self = [super init]) {
		oscManager = [manager retain];
		oscPort = [[oscManager createNewInputForPort:p withLabel:l] retain];
		oscPort.delegate = self;
		delegates = [[NSMutableSet alloc] init];
	}
	return self;
}
-(void)dealloc {
	[oscManager release];
	[oscPort release];
	[delegates release];
	[super dealloc];
}
-(void)addDelegate:(id)delegate {
	[delegates addObject:delegate];
}
-(void)removeDelegate:(id)delegate {
	[delegates removeObject:delegate];
}
- (unsigned short) port {
	return [oscPort port];
}
- (NSString *) portLabel {
	return [oscPort portLabel];
}
-(void)remove {
	[oscManager removeInput:oscPort];
}

- (void) receivedOSCMessage:(OSCMessage *)m {
	[delegates makeObjectsPerformSelector:@selector(receivedOSCMessage:) withObject:m];
}
@end
