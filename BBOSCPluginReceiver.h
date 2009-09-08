//
//  BBOSCPluginReceiverPlugIn.h
//  BBOSC
//
//  Created by Jonathan del Strother on 08/09/2009.
//  Copyright (c) 2009 Best Before Media Ltd. All rights reserved.
//

#import <Quartz/Quartz.h>

@class OSCManager, OSCInPort;
@interface BBOSCPluginReceiver : QCPlugIn
{
	OSCManager				*oscManager;
    OSCInPort				*oscPort;
	NSMutableArray* messages;
	NSLock* messageLock;
}

@property (nonatomic, readwrite, assign) NSArray* outputStructure;

@end
