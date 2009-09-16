//
//  BBOSCInPort.h
//  BBOSC
//
//  Created by Jonathan del Strother on 16/09/2009.
//  Copyright 2009 Best Before Media Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// This is a basic wrapper around OSCInPort, with the addition of handling multiple delegates

@class OSCInPort, OSCManager;
@interface BBOSCInPort : NSObject {
	OSCManager* oscManager;
	OSCInPort* oscPort;
	NSMutableSet* delegates;
}
-(id)initWithManager:(OSCManager*)manager withPort:(unsigned int)p label:(NSString*)l;
-(void)addDelegate:(id)delegate;
-(void)removeDelegate:(id)delegate;
-(unsigned short)port;
-(NSString*)portLabel;
-(void)remove;
@end
