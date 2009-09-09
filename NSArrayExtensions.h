//
//  NSArrayExtensions.h
//  BBOSC
//
//  Created by Jonathan del Strother on 09/09/2009.
//  Copyright 2009 Best Before Media Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSArray(BBExtensions)
- (NSArray *)map: (id (^)(id obj))block;
- (NSArray *)select: (BOOL (^)(id obj))block;
-(NSDictionary*)qcStructure;
@end
