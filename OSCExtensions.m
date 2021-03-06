//
//  OSCExtensions.m
//  BBOSC
//
//  Created by Jonathan del Strother on 09/09/2009.
//  Copyright 2009 Best Before Media Ltd. All rights reserved.
//

#import "OSCExtensions.h"

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

-(id)readNSValueFromPosition:(NSUInteger*)pos withBias:(BBOSCType)bias forceType:(BOOL)forceType{
	
	if (bias >= BBOSCTypeArrayOfInt) {
		NSMutableArray* result = [NSMutableArray array];
		while(*pos<self.valueCount) {
			id subvalue = [self readNSValueFromPosition:pos withBias:bias-4 forceType:NO];	// Treat the arrays as loosely typed so strings don't get mangled
			if (!subvalue)
				break;
			[result addObject:subvalue];
		}
		return result;
	}
	
	OSCValue* oscValue;
	if (*pos >= self.valueCount)
		oscValue = nil;
	else if (self.valueCount==1 && *pos==0)
		oscValue = [self value];
	else
		oscValue = [self valueAtIndex:*pos];
	(*pos)++;
	
	if ([oscValue type] == OSCValNil)
		return [NSNull null];
				
	id outputValue = nil;	
	if (forceType) {	// Use the 'bias' type, assume the user knows what he's doing.
		switch (bias) {
			case BBOSCTypeBool:
				outputValue = [NSNumber numberWithBool:[oscValue boolValue]];
				break;
			case BBOSCTypeInt:
				outputValue = [NSNumber numberWithInt:[oscValue intValue]];
				break;
			case BBOSCTypeFloat:
				outputValue = [NSNumber numberWithFloat:[oscValue floatValue]];
				break;
			case BBOSCTypeString:
				outputValue = [oscValue stringValue];
				break;
		}
	} else {	// Use the OSC type
		switch([oscValue type]) {
			case OSCValBool:
				outputValue = [NSNumber numberWithBool:[oscValue boolValue]];
				break;
			case OSCValInt:
				outputValue = [NSNumber numberWithInt:[oscValue intValue]];
				break;
			case OSCValFloat:
				outputValue = [NSNumber numberWithFloat:[oscValue floatValue]];
				break;
			case OSCValString:
				outputValue = [oscValue stringValue];
				break;
		}
	}
	
	return outputValue;
}

-(id)readNSValueFromPosition:(NSUInteger*)pos withBias:(BBOSCType)bias {
	return [self readNSValueFromPosition:pos withBias:bias forceType:YES];
}
@end
