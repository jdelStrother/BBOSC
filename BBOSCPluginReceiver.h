//
//  BBOSCPluginReceiverPlugIn.h
//  BBOSC
//
//  Created by Jonathan del Strother on 08/09/2009.
//  Copyright (c) 2009 Best Before Media Ltd. All rights reserved.
//

#import <Quartz/Quartz.h>

@class BBOSCInPort;
@interface BBOSCPluginReceiver : QCPlugIn {
	NSMutableArray* messages;
	NSLock* messageLock;
	id oscPort, oscParameters, listeningPath, retryTime;
}
@property (nonatomic, readonly, retain) NSString* listeningPath;
@property (nonatomic, readonly, retain) NSArray* oscParameters;
@property (nonatomic, readonly, retain) BBOSCInPort *oscPort;
@property (nonatomic, readonly, retain) NSDate* retryTime; 

@property (nonatomic, readwrite, assign) BOOL inputDiscardExcessMessages;
@property (nonatomic, readwrite, assign) NSUInteger inputReceivingPort;
@property (nonatomic, readwrite, assign) NSString* inputLabel;
@property (nonatomic, readwrite, assign) NSString* inputReceivingPath;
@property (nonatomic, readwrite, assign) BOOL outputError;
@property (nonatomic, readwrite, assign) BOOL outputMessageReceived;
@property (nonatomic, readwrite, assign) NSString* outputMessagePath;
@end
