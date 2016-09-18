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
- (id)ct_first:(CollectorConditionBlock)condition orDefault:(id)defaultObject;
- (id)ct_last:(CollectorConditionBlock)condition;
- (id)ct_last:(CollectorConditionBlock)condition orDefault:(id)defaultObject;
- (NSArray *)ct_where:(CollectorConditionBlock)condition;
- (NSArray *)ct_map:(CollectorValueBlock)gatheringBlock;
- (id)ct_reduce:(id(^)(id cumulated, id object))reducingBlock;
- (id)ct_reduceWithSeed:(id)seed block:(id(^)(id cumulated, id object))reducingBlock;
- (void)ct_each:(CollectorOperationBlock)operation;
- (void)ct_eachWithIndex:(void(^)(id object, NSUInteger index, BOOL *stop))operation;
- (NSArray *)ct_except:(CollectorConditionBlock)condition;
- (NSArray *)ct_take:(NSUInteger)amount;
- (NSArray *)ct_distinct;
- (NSArray *)ct_distinct:(CollectorValueBlock)valueBlock;
- (NSArray *)ct_objectsInRange:(NSRange)range;
- (NSArray *)ct_objectsOfKind:(Class)kind;
- (id)ct_winner:(id(^)(id object1, id object2))comparisonBlock;
- (BOOL)ct_all:(CollectorConditionBlock)testBlock;
- (BOOL)ct_any:(CollectorConditionBlock)testBlock;
- (BOOL)ct_none:(CollectorConditionBlock)testBlock;
- (NSUInteger)ct_count:(CollectorConditionBlock)testBlock;

@end
