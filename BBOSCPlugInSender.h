//
//  BBOSCPlugInSender.h
//  BBOSC
//
//  Created by Jonathan del Strother on 08/09/2009.
//  Copyright (c) 2009 Best Before Media Ltd. All rights reserved.
//

#import <Quartz/Quartz.h>

@class OSCManager, OSCOutPort;
@interface BBOSCPlugInSender : QCPlugIn {
	id oscPort, oscParameters;
}
@property (nonatomic, readonly, retain) OSCOutPort *oscPort;
@property (nonatomic, readonly, retain) NSArray* oscParameters;

@property (nonatomic, readwrite, assign) NSString* inputBroadcastAddress;
@property (nonatomic, readwrite, assign) NSUInteger inputBroadcastPort;
@property (nonatomic, readwrite, assign) NSString* inputBroadcastPath;
@property (nonatomic, readwrite, assign) BOOL inputTickle;

@end
