//
//  BBOSCViewController.h
//  BBOSC
//
//  Created by Jonathan del Strother on 09/09/2009.
//  Copyright 2009 Best Before Media Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* BBOSCTypeKey;
extern NSString* BBOSCPortKey;

typedef enum {
	BBOSCTypeInt,
	BBOSCTypeFloat,
	BBOSCTypeBool,	
	BBOSCTypeString,
	BBOSCTypeArrayOfInt,
	BBOSCTypeArrayOfFloat,
	BBOSCTypeArrayOfBool,
	BBOSCTypeCount
} BBOSCType;

@interface BBOSCViewController : QCPlugInViewController {
	id portTypeDropDown, portArrayController;
}
@property (nonatomic, readonly, assign) IBOutlet NSPopUpButton* portTypeDropDown;
@property (nonatomic, readonly, assign) IBOutlet NSArrayController* portArrayController;
-(IBAction)addNewPort:(id)sender;
@end

@interface BBOSCTypeToStringTransformer : NSValueTransformer
+ (id) transformer;
@end

NSString* QCTypeForOSCType(BBOSCType oscType);