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

- (NSArray *)ct_arrayByRemovingObject:(id)object;
- (NSArray *)ct_arrayByRemovingObjectsInArray:(NSArray *)array;

#pragma mark Block-based Array Manipulation and Filtering

- (id)ct_first:(CollectorConditionBlock)condition;
- (NSArray *)ct_where:(CollectorConditionBlock)condition;
- (NSArray *)ct_map:(CollectorValueBlock)gatheringBlock;
- (NSArray *)ct_distinct;
- (BOOL)ct_any:(CollectorConditionBlock)testBlock;

@end
