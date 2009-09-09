//
//  BBOSCPlugInSender.m
//  BBOSC
//
//  Created by Jonathan del Strother on 08/09/2009.
//  Copyright (c) 2009 Best Before Media Ltd. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>
#import "vvosc/FrameworkSrc/VVOSC.h"

#import "BBOSCViewController.h"
#import "BBOSCPlugInSender.h"
#import "NSArrayExtensions.h"

#define	kQCPlugIn_Name				@"BBOSC Sender"
#define	kQCPlugIn_Description		@"Best Before Open Sound Control sender plugin"


@interface OSCMessage(BBExtensions)
-(void)addNSValue:(id)newValue withBias:(BBOSCType)bias;
@end
@implementation OSCMessage(BBExtensions)
-(void)addNSValue:(id)newValue withBias:(BBOSCType)bias {

	if ([newValue isKindOfClass:[NSString class]]) {
		[self addString:newValue];
		
	} else if ([newValue isKindOfClass:[NSNumber class]]) {
		switch(bias) {
			case BBOSCTypeBool:
				[self addBOOL:[newValue boolValue]];
				break;
			case BBOSCTypeInt:
				[self addInt:[newValue intValue]];
				break;
			case BBOSCTypeFloat:
				[self addFloat:[newValue floatValue]];
				break;
			default:
				NSAssert2(NO, @"Bad type %d for %@", bias, newValue);
		}
	
	} else if ([newValue isKindOfClass:[NSArray class]]) {
		NSAssert2(bias>=BBOSCTypeArrayOfInt && bias<=BBOSCTypeArrayOfBool, @"Unexpected value %@ for type %d", newValue, bias);
		// We've got an array - add all the subvalues into the message, using the appropriate type (eg if we're using BBOSCTypeArrayOfFloat, subvalues should use BBOSCTypeFloat)
		for(id subvalue in newValue) {
			[self addNSValue:subvalue withBias:bias-4];
		}
		
	} else {
		[self addBOOL:!!newValue];
	}
}
@end



@interface BBOSCPlugInSender ()
@property (nonatomic, readwrite, retain) OSCManager *oscManager;
@property (nonatomic, readwrite, retain) OSCOutPort *oscPort;
@property (nonatomic, readwrite, retain) NSArray* oscParameters;

@end

@implementation BBOSCPlugInSender
@synthesize oscManager, oscPort, oscParameters;
@dynamic inputBroadcastPort, inputBroadcastPath;

+ (NSDictionary*) attributes
{
	/*
	Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
	*/
	
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key {
	if ([key isEqualToString:@"inputBroadcastPort"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Broadcast Port", QCPortAttributeNameKey,
				[NSNumber numberWithInt:60000], QCPortAttributeDefaultValueKey, nil];
	}
	if ([key isEqualToString:@"inputBroadcastPath"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Broadcast Path", QCPortAttributeNameKey,
				@"/test", QCPortAttributeDefaultValueKey, nil];
	}
	
	return nil;
}

+ (QCPlugInExecutionMode) executionMode
{
	/*
	Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	*/
	
	return kQCPlugInExecutionModeConsumer;
}

+ (QCPlugInTimeMode) timeMode
{
	/*
	Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	*/
	
	return kQCPlugInTimeModeNone;
}

- (id) init
{
	if(self = [super init]) {
		/*
		Allocate any permanent resource required by the plug-in.
		*/
		self.oscManager = [[[OSCManager alloc] init] autorelease];

		self.oscParameters = [NSArray array];
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
	[oscManager release];
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
		[self removeInputPortForKey:portKey];
	}
	
	for(NSDictionary* port in oscParameters) {
		NSString* key = [port objectForKey:BBOSCPortKey];
		NSNumber* oscType = [port objectForKey:BBOSCTypeKey];
		NSString* name = [NSString stringWithFormat:@"OSC-%@", [[BBOSCTypeToStringTransformer transformer] transformedValue:oscType]];
		NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:name, QCPortAttributeNameKey, nil];

		[self addInputPortWithType:QCTypeForOSCType([oscType intValue]) forKey:key withAttributes:attributes];
	}
}

-(NSArray*)oscParameters {
	return oscParameters;
}

@end

@implementation BBOSCPlugInSender (Execution)

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
	
	BOOL inputsChanged = NO;
	
	if ([self didValueForInputKeyChange:@"inputBroadcastPort"]) {
		if (self.oscPort)
			[self.oscManager removeOutput:self.oscPort];
		self.oscPort = [self.oscManager createNewOutputToAddress:@"0.0.0.0" atPort:self.inputBroadcastPort withLabel:@"BB OSC"];
		inputsChanged = YES;
	}

	for(NSDictionary* port in oscParameters) {
		NSString* key = [port objectForKey:BBOSCPortKey];
		if ([self didValueForInputKeyChange:key]) {
			inputsChanged = YES;
			break;
		}
	}
	if ([self didValueForInputKeyChange:@"inputBroadcastPath"])
		inputsChanged = YES;
	
	if (!inputsChanged)
		return YES;
	
	OSCMessage* message = [OSCMessage createWithAddress:self.inputBroadcastPath];
	
	for(NSDictionary* port in oscParameters) {
		NSString* key = [port objectForKey:BBOSCPortKey];
		id value = [self valueForInputKey:key];
		BBOSCType oscType = [[port objectForKey:BBOSCTypeKey] intValue];
		
		[message addNSValue:value withBias:oscType];
	}
		
	[self.oscPort sendThisMessage:message];
	
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
}

@end
