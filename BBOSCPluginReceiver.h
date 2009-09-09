//
//  BBOSCPluginReceiverPlugIn.h
//  BBOSC
//
//  Created by Jonathan del Strother on 08/09/2009.
//  Copyright (c) 2009 Best Before Media Ltd. All rights reserved.
//

#import <Quartz/Quartz.h>

@class OSCManager, OSCInPort;
@interface BBOSCPluginReceiver : QCPlugIn {
	NSMutableArray* messages;
	NSLock* messageLock;
}
@property (nonatomic, readonly, retain) NSString* listeningPath;

@property (nonatomic, readonly, retain) NSArray* oscParameters;

@property (nonatomic, readonly, retain) OSCManager *oscManager;
@property (nonatomic, readonly, retain) OSCInPort *oscPort;  

@property (nonatomic, readwrite, assign) NSUInteger inputReceivingPort;
@property (nonatomic, readwrite, assign) NSString* inputReceivingPath;
@property (nonatomic, readwrite, assign) BOOL outputMessageReceived;
@end
