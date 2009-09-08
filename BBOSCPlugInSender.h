//
//  BBOSCPlugInSender.h
//  BBOSC
//
//  Created by Jonathan del Strother on 08/09/2009.
//  Copyright (c) 2009 Best Before Media Ltd. All rights reserved.
//

#import <Quartz/Quartz.h>

@class OSCManager, OSCOutPort;
@interface BBOSCPlugInSender : QCPlugIn
{
	OSCManager				*oscManager;
    OSCOutPort				*oscPort;
}

@property (nonatomic, readwrite, assign) NSUInteger inputBroadcastPort;

@end
