//
//  BBOSCPluginReceiverPlugIn.m
//  BBOSC
//
//  Created by Jonathan del Strother on 08/09/2009.
//  Copyright (c) 2009 Best Before Media Ltd. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>
#import "vvosc/FrameworkSrc/VVOSC.h"
#import "BBOSCPluginReceiver.h"

#define	kQCPlugIn_Name				@"BBOSC Receiver"
#define	kQCPlugIn_Description		@"Best Before Open Sound Control receiver plugin"

@implementation BBOSCPluginReceiver
@dynamic outputStructure;

+ (NSDictionary*) attributes
{
	/*
	Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
	*/
	
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/*
	Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
	*/
	
	return nil;
}

+ (QCPlugInExecutionMode) executionMode
{
	/*
	Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	*/
	
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode) timeMode
{
	/*
	Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	*/
	
	return kQCPlugInTimeModeIdle;
}

- (id) init
{
	if(self = [super init]) {
		oscManager = [[OSCManager alloc] init];
		oscManager.delegate = self;
		messages = [[NSMutableArray alloc] init];
		messageLock = [[NSLock alloc] init];
	}
	
	return self;
}

- (void) finalize
{
	/*
	Release any non garbage collected resources created in -init.
	*/
	
	[super finalize];
}

- (void) dealloc
{
	[oscPort release];
	oscManager.delegate = nil;
	[oscManager release];
	[messages release];
	[messageLock release];
	[super dealloc];
}

- (void) receivedOSCMessage:(OSCMessage *)m {
	// TODO : Needs to be thread safe
	if ([[m address] isEqualToString:@"/test"]) {
		[messageLock lock];
		[messages addObject:m];
		[messageLock unlock];
	}
}
@end

@implementation BBOSCPluginReceiver (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	*/
	oscPort = [[oscManager createNewInputForPort:60000 withLabel:@"BB OSC"] retain];
	return YES;
}

- (void) enableExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
	*/
}

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	
	The OpenGL context for rendering can be accessed and defined for CGL macros using:
	CGLContextObj cgl_ctx = [context CGLContextObj];
	*/
	
	[messageLock lock];
	if ([messages count]>0) {
		OSCMessage* message = [messages objectAtIndex:0];
		NSLog(@"Yay %@", message);
		NSMutableArray* messageContent = [NSMutableArray array];
		for(OSCValue* oscValue in [message valueArray]) {
			switch (oscValue.type) {
				case OSCValInt:
					[messageContent addObject:[NSNumber numberWithInt:[oscValue intValue]]];
					break;
				case OSCValFloat:
					[messageContent addObject:[NSNumber numberWithFloat:[oscValue floatValue]]];
					break;
				case OSCValString:
					[messageContent addObject:[oscValue stringValue]];
					break;
				case OSCValBool:
					[messageContent addObject:[NSNumber numberWithBool:[oscValue boolValue]]];
					break;
				default:
					NSLog(@"Ignoring object value %@", oscValue);
					break;
			}
		}
		self.outputStructure = messageContent;
		[messages removeObjectAtIndex:0];
	}
	[messageLock unlock];
	
	return YES;
}

- (void) disableExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	*/
}

- (void) stopExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	*/
	[oscManager removeOutput:oscPort];
	[oscPort release];
	oscPort = nil;
}

@end
