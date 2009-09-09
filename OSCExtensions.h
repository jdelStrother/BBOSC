//
//  OSCExtensions.h
//  BBOSC
//
//  Created by Jonathan del Strother on 09/09/2009.
//  Copyright 2009 Best Before Media Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "vvosc/FrameworkSrc/VVOSC.h"
#import "BBOSCViewController.h"

@interface OSCMessage(BBExtensions)
-(void)addNSValue:(id)newValue withBias:(BBOSCType)bias;
-(id)readNSValueFromPosition:(NSUInteger*)pos withBias:(BBOSCType)bias;	// Returns an NS object from the value at *pos.  Increments *pos by the number of positions it ends up reading
@end
