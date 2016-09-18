//
//  NSArray+Collector.m
//  Collector
//
//  Created by Michaël Fortin on 12-07-09.
//  Copyright (c) 2012 irradiated.net. All rights reserved.
//

#import "NSArray+FilesAdditions.h"

@implementation NSArray (FilesAdditions)

#pragma mark Creating Other Instances

- (NSArray *)ct_arrayByRemovingObject:(id)object
{
	return [self ct_arrayByRemovingObjectsInArray:@[object]];
}

- (NSArray *)ct_arrayByRemovingObjectsInArray:(NSArray *)array
{
	NSMutableArray *newArray = [self mutableCopy];
	[newArray removeObjectsInArray:array];
	return [newArray copy];
}

#pragma mark Block-based Array Manipulation and Filtering

- (id)ct_first:(CollectorConditionBlock)condition
{
	for (id object in self)
		if (condition(object)) return object;
	
	return nil;
}

- (NSArray *)ct_where:(CollectorConditionBlock)condition
{
	NSMutableArray *selectedObjects = [NSMutableArray array];
	
	for (id obj in self)
	{
		if (condition(obj))
			[selectedObjects addObject:obj];
	}
	
	return [selectedObjects copy];
}

- (NSArray *)ct_map:(CollectorValueBlock)valueBlock
{
	NSMutableArray *values = [NSMutableArray array];
	
	for (id obj in self)
	{
		id value = valueBlock(obj);
		if (value != nil) [values addObject:value];
	}
	
	return [values copy];
}

- (NSArray *)ct_distinct
{
	NSMutableArray *distinct = [NSMutableArray array];
	
	for (id object in self)
	{
		if ([distinct indexOfObject:object] == NSNotFound)
			[distinct addObject:object];
	}
	
	return [distinct copy];
}

- (BOOL)ct_any:(CollectorConditionBlock)testBlock
{
	for (id object in self)
		if (testBlock(object)) return YES;
	
	return NO;
}

@end
