//
//  ThreadLoop.m
//  VVOSC
//
//  Created by bagheera on 2/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ThreadLoop.h"




@implementation ThreadLoop


- (id) initWithTimeInterval:(float)i target:(id)t selector:(SEL)s	{
	//NSLog(@"%s",__func__);
	if ((t==nil) || (s==nil) || (![t respondsToSelector:s]))
		return nil;
	if (self = [super init])	{
		interval = i;
		running = NO;
		bail = NO;
		targetObj = t;
		targetSel = s;
		return self;
	}
	[self release];
	return nil;
}
- (id) initWithTimeInterval:(float)i	{
	//NSLog(@"%s",__func__);
	if (self = [super init])	{
		interval = i;
		running = NO;
		bail = NO;
		targetObj = nil;
		targetSel = nil;
		return self;
	}
	[self release];
	return nil;
}
- (void) dealloc	{
	//NSLog(@"%s",__func__);
	[self stopAndWaitUntilDone];
	targetObj = nil;
	targetSel = nil;
	[super dealloc];
}
- (void) start	{
	//NSLog(@"%s",__func__);
	if (running) return;
	[NSThread
		detachNewThreadSelector:@selector(threadCallback)
		toTarget:self
		withObject:nil];
}
- (void) threadCallback	{
	//NSLog(@"%s",__func__);
	NSAutoreleasePool		*pool = [[NSAutoreleasePool alloc] init];
	int						runLoopCount = 0;
	
	running = YES;
	bail = NO;
	
	while ((running) && (!bail))	{
		//NSLog(@"\t\tproc");
		struct timeval		startTime;
		struct timeval		stopTime;
		float				executionTime;
		float				sleepDuration;	//	in microseconds!
		
		gettimeofday(&startTime,NULL);
		//@try	{
			//	if there's a target object, ping it (delegate-style)
			if (targetObj != nil)
				[targetObj performSelector:targetSel];
			//	else just call threadProc (subclass-style)
			else
				[self threadProc];
		//}
		//@catch (NSException *err)	{
		//	NSLog(@"%s caught exception, %@",__func__,err);
		//}
		++runLoopCount;
		if (runLoopCount > 128)	{
			//NSLog(@"\t\tabout to drain the pool");
			[pool release];
			pool = [[NSAutoreleasePool alloc] init];
			runLoopCount = 0;
			//NSLog(@"\t\tdone draining the pool");
		}
		
		//	figure out how long it took to run the callback
		gettimeofday(&stopTime,NULL);
		while (stopTime.tv_sec > startTime.tv_sec)	{
			--stopTime.tv_sec;
			stopTime.tv_usec = stopTime.tv_usec + 1000000;
		}
		//NSLog(@"\t\t%ld, %ld",stopTime.tv_usec,startTime.tv_usec);
		executionTime = (float)(stopTime.tv_usec-startTime.tv_usec);
		//NSLog(@"\t\t%f",executionTime/1000000.0);
		sleepDuration = interval - (executionTime/1000000.0);
		//NSLog(@"\t\t%f",sleepDuration);
		
		
		//	only sleep if duration's > 0, sleep for a max of 1 sec
		if (sleepDuration > 0)	{
			if (sleepDuration > 1)
				sleepDuration = 1;
			[NSThread sleepForTimeInterval:sleepDuration];
		}
		
		
		/*
		//	simple check- make sure sleep duration's between 0 & 1, then always sleep
		if (sleepDuration < 0)
			sleepDuration = 0;
		else if (sleepDuration > 1)
			sleepDuration = 1;
		[NSThread sleepForTimeInterval:sleepDuration];
		*/
		
		//NSLog(@"\t\tproc done");
	}
	//NSLog(@"\tthread exiting");
	[pool release];
	running = NO;
	//NSLog(@"\t\t%s - FINSHED",__func__);
}
- (void) threadProc	{
	
}
- (void) stop	{
	//NSLog(@"%s",__func__);
	if (!running)
		return;
	bail = YES;
}
- (void) stopAndWaitUntilDone	{
	//NSLog(@"%s",__func__);
	[self stop];
	while (running)	{
	
	}
}
- (void) setInterval:(float)i	{
	interval = (i > 1.0) ? 1.0 : i;
}
- (BOOL) running	{
	return running;
}


@end
