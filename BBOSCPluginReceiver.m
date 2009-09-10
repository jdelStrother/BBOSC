//
//  BBOSCPluginReceiverPlugIn.m
//  BBOSC
//
//  Created by Jonathan del Strother on 08/09/2009.
//  Copyright (c) 2009 Best Before Media Ltd. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>
#import "BBOSCPluginReceiver.h"
#import "BBOSCViewController.h"
#import "NSArrayExtensions.h"
#import "OSCExtensions.h"
#import "BBOSCManager.h"

#define	kQCPlugIn_Name				@"BBOSC Receiver"
#define	kQCPlugIn_Description		@"Best Before Open Sound Control receiver plugin"

@interface BBOSCPluginReceiver ()
@property (nonatomic, readwrite, retain) OSCOutPort *oscPort;
@property (nonatomic, readwrite, retain) NSArray* oscParameters;
@property (nonatomic, readwrite, retain) NSString* listeningPath;
@end

@implementation BBOSCPluginReceiver
@dynamic inputDiscardExcessMessages, inputReceivingPort, inputReceivingPath, outputMessageReceived, outputMessagePath;
@synthesize oscPort, oscParameters, listeningPath;

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
	if ([key isEqualToString:@"inputReceivingPort"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Receiving Port", QCPortAttributeNameKey,
				[NSNumber numberWithInt:60000], QCPortAttributeDefaultValueKey, nil];
	}
	if ([key isEqualToString:@"inputDiscardExcessMessages"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Discard Excess Messages", QCPortAttributeNameKey,
				[NSNumber numberWithBool:NO], QCPortAttributeDefaultValueKey, nil];
	}
	if ([key isEqualToString:@"inputReceivingPath"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Receiving Path", QCPortAttributeNameKey,
				@"", QCPortAttributeDefaultValueKey, nil];
	}
	if ([key isEqualToString:@"outputMessageReceived"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Message Received", QCPortAttributeNameKey, nil];
	}
	
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
		[[BBOSCManager sharedManager] addDelegate:self];
		self.oscParameters = [NSArray array];
		messages = [[NSMutableArray alloc] init];
		messageLock = [[NSLock alloc] init];
		listeningPath = @"";
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
	[[BBOSCManager sharedManager] removeDelegate:self];
	[oscPort release];
	[messages release];
	[messageLock release];
	[listeningPath release];
	[oscParameters release];
	[super dealloc];
}

- (QCPlugInViewController*) createViewController
{
	return [[BBOSCViewController alloc] initWithPlugIn:self
										   viewNibName:@"BBOSCSettings"];
}

+ (NSArray*) plugInKeys {
	return [NSArray arrayWithObjects:@"oscParameters", nil];
}

-(void)setOscParameters:(NSArray*)params {
	NSArray* originalPortKeys = [oscParameters map:^(id port){ return [port objectForKey:BBOSCPortKey]; }];
	
	[self willChangeValueForKey:@"oscParameters"];
	[oscParameters release];
	oscParameters = [params retain];
	[self didChangeValueForKey:@"oscParameters"];
	
	// Bleh, just trash all the original input ports
	for(NSString* portKey in originalPortKeys) {
		[self removeOutputPortForKey:portKey];
	}
	
	for(NSDictionary* port in oscParameters) {
		NSString* key = [port objectForKey:BBOSCPortKey];
		NSNumber* oscType = [port objectForKey:BBOSCTypeKey];
		NSString* name = [NSString stringWithFormat:@"OSC-%@", [[BBOSCTypeToStringTransformer transformer] transformedValue:oscType]];
		NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:name, QCPortAttributeNameKey, nil];
		
		[self addOutputPortWithType:QCTypeForOSCType([oscType intValue]) forKey:key withAttributes:attributes];
	}
}


- (void) receivedOSCMessage:(OSCMessage *)m {
	[messageLock lock];
	if ([[m address] hasPrefix:self.listeningPath]) {
		[messages addObject:m];
	}
	[messageLock unlock];
}
@end

@implementation BBOSCPluginReceiver (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	*/
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
	
	if ([self didValueForInputKeyChange:@"inputReceivingPath"]) {
		[messageLock lock];
		self.listeningPath = self.inputReceivingPath;
		[messages removeAllObjects];
		[messageLock unlock];
	}
	
	if ([self didValueForInputKeyChange:@"inputReceivingPort"]) {
		if (self.oscPort)
			[[BBOSCManager sharedManager] removeInput:self.oscPort];
		self.oscPort = [[BBOSCManager sharedManager] createNewInputForPort:self.inputReceivingPort withLabel:@"BB OSC"];
		if (!self.oscPort)
			NSLog(@"Failed to created input port");
	}
	
	[messageLock lock];
	if ([messages count]==0) {
		self.outputMessageReceived = NO;
	} else {
		self.outputMessageReceived = YES;
		
		OSCMessage* message = [messages objectAtIndex:0];
		
		NSUInteger valueIndex=0;
		for(NSDictionary* port in oscParameters) {
			BBOSCType expectedType = [[port objectForKey:BBOSCTypeKey] intValue];
			NSString* portKey = [port objectForKey:BBOSCPortKey];
						
			id outputValue = [message readNSValueFromPosition:&valueIndex withBias:expectedType];
			// Grr, no assigning arrays to QCStructures.  rdar://5672284
			if ([outputValue isKindOfClass:[NSArray class]])
				outputValue = [outputValue qcStructure];
			
			[self setValue:outputValue forOutputKey:portKey];
		}
		
		self.outputMessagePath = [message address];

		// If we want to be super-responsive, trash any extra messages that are received that we didn't get around to processing this frame
		// If we want to catch every single message, leave them in a queue to be processed in a later frame.
		if (self.inputDiscardExcessMessages)
			[messages removeAllObjects];
		else
			[messages removeObjectAtIndex:0];
	}
	[messageLock unlock];
	
	return YES;
}

- (void) disableExecution:(id<QCPlugInContext>)context
{
	if (self.oscPort) {
		[[BBOSCManager sharedManager] removeOutput:self.oscPort];
		self.oscPort = nil;
	}
}

- (void) stopExecution:(id<QCPlugInContext>)context {

}

@end
