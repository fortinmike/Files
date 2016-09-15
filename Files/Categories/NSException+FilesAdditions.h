//
//  NSException+FilesAdditions.h
//  Obsidian
//
//  Created by Michaël Fortin on 2013-05-07.
//  Copyright (c) 2013 Michaël Fortin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSException (FilesAdditions)

+ (instancetype)exceptionWithReason:(NSString *)reason, ... NS_FORMAT_FUNCTION(1, 2);

@end
