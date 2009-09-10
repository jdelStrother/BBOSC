//
//  BBOSCManager.h
//  BBOSC
//
//  Created by Jonathan del Strother on 10/09/2009.
//  Copyright 2009 Best Before Media Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OSCManager, OSCInPort, OSCOutPort;
@interface BBOSCManager : NSObject {
	NSMutableArray* delegates;
	OSCManager* oscManager;
	NSLock* delegateLock;
}
+(id)sharedManager;
-(void)addDelegate:(id)delegate;
-(void)removeDelegate:(id)delegate;

- (OSCInPort*)createNewInputForPort:(int)p withLabel:(NSString *)l;
- (OSCOutPort*)createNewOutputToAddress:(NSString *)a atPort:(int)p withLabel:(NSString *)l;
- (void)removeInput:(id)p;
- (void)removeOutput:(id)p;
@end
