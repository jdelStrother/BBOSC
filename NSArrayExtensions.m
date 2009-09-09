//
//  NSArrayExtensions.m
//  BBOSC
//
//  Created by Jonathan del Strother on 09/09/2009.
//  Copyright 2009 Best Before Media Ltd. All rights reserved.
//

#import "NSArrayExtensions.h"


@implementation NSArray(BBExtensions)
- (NSArray *)map: (id (^)(id obj))block
{
	NSMutableArray *new = [NSMutableArray array];
	for(id obj in self)
	{
		id newObj = block(obj);
		[new addObject: newObj ? newObj : [NSNull null]];
	}
	return new;
}


- (NSArray *)select: (BOOL (^)(id obj))block
{
	NSMutableArray *new = [NSMutableArray array];
	for(id obj in self)
	{
		BOOL selected = block(obj);
		if (selected)
			[new addObject:obj];
	}
	return new;
}

-(NSDictionary*)qcStructure {
	int i=0;
	NSMutableDictionary* result = [NSMutableDictionary dictionary];
	for(id object in self) {
		[result setObject:object forKey:[NSNumber numberWithInt:i++]];
	}
	return result;
}
@end
