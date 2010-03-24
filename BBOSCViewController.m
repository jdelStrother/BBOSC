//
//  BBOSCViewController.m
//  BBOSC
//
//  Created by Jonathan del Strother on 09/09/2009.
//  Copyright 2009 Best Before Media Ltd. All rights reserved.
//

#import "BBOSCViewController.h"

NSString* BBOSCTypeKey=@"BBOSCType";
NSString* BBOSCPortKey=@"BBOSCPortKey";

@implementation BBOSCTypeToStringTransformer
+ (id) transformer {
	return [[[self alloc] init] autorelease];
}
+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }
- (id)transformedValue:(id)value {
	switch ([value intValue]) {
		case BBOSCTypeInt: return @"Integer";
		case BBOSCTypeFloat: return @"Float";
		case BBOSCTypeBool: return @"Boolean";
		case BBOSCTypeString: return @"String";
		case BBOSCTypeArrayOfInt: return @"Array w/ Int bias";
		case BBOSCTypeArrayOfFloat: return @"Array w/ Float bias";
		case BBOSCTypeArrayOfBool: return @"Array w/ Bool bias";
	}
	NSAssert1(NO, @"Bad OSC type value %@", value);
	return nil;
}
@end

@implementation BBOSCViewController
@synthesize portTypeDropDown, portArrayController;

+(void)initialize {
	if (self == [BBOSCViewController class]) {
		[NSValueTransformer setValueTransformer:[BBOSCTypeToStringTransformer transformer] forName:@"BBOSCTypeToStringTransformer"];
	}
}

-(void)setPortTypeDropDown:(NSPopUpButton*)popup {
	// Initialize the popup with all our port types
	portTypeDropDown = popup;
	[portTypeDropDown removeAllItems];
	NSMutableArray* portTypes = [NSMutableArray array];
	BBOSCTypeToStringTransformer* transformer = [BBOSCTypeToStringTransformer transformer];
	for(int i=0; i<BBOSCTypeCount; i++) {
		[portTypes addObject:[transformer transformedValue:[NSNumber numberWithInt:i]]];
	}
	[portTypeDropDown addItemsWithTitles:portTypes];
}

-(void)addNewPort:(id)sender {
	NSMutableDictionary* newPort = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:[portTypeDropDown indexOfSelectedItem]],BBOSCTypeKey,
									[[NSProcessInfo processInfo] globallyUniqueString], BBOSCPortKey, nil
									];
	[portArrayController addObject:newPort];
}

@end

NSString* QCTypeForOSCType(BBOSCType oscType) {
	switch(oscType) {
		case BBOSCTypeBool: return QCPortTypeBoolean;
		case BBOSCTypeInt: return QCPortTypeIndex;
		case BBOSCTypeFloat: return QCPortTypeNumber;
		case BBOSCTypeString: return QCPortTypeString;
		default: return QCPortTypeStructure;
	}
}