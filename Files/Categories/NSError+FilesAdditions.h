//
//  NSError+FilesAdditions.h
//  Obsidian
//
//  Created by Michaël Fortin on 2013-01-18.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (FilesAdditions)

+ (instancetype)errorWithDescription:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);

@end
