//
//  NSArray+Collector.h
//  Collector
//
//  Created by Michaël Fortin on 12-07-09.
//  Copyright (c) 2012 irradiated.net. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CollectorOperationBlock)(id object);
typedef BOOL (^CollectorConditionBlock)(id object);
typedef id (^CollectorValueBlock)(id object);
typedef NSNumber * (^CollectorNumberBlock)(id object);

@interface NSArray (FilesAdditions)

#pragma mark Creating Other Instances

- (NSArray *)files_arrayByRemovingObject:(id)object;
- (NSArray *)files_arrayByRemovingObjectsInArray:(NSArray *)array;

#pragma mark Block-based Array Manipulation and Filtering

- (id)files_first:(CollectorConditionBlock)condition;
- (NSArray *)files_where:(CollectorConditionBlock)condition;
- (NSArray *)files_map:(CollectorValueBlock)gatheringBlock;
- (NSArray *)files_distinct;
- (BOOL)files_any:(CollectorConditionBlock)testBlock;

@end
