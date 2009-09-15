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
	OSCManager* oscManager;
}
+(id)sharedManager;

- (OSCInPort*)createNewInputForPort:(int)p withLabel:(NSString *)l;
- (OSCOutPort*)createNewOutputToAddress:(NSString *)a atPort:(int)p withLabel:(NSString *)l;
- (void)removeInput:(id)p;
- (void)removeOutput:(id)p;
@end
