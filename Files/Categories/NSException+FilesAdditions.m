//
//  NSException+FilesAdditions.m
//  Obsidian
//
//  Created by Michaël Fortin on 2013-05-07.
//  Copyright (c) 2013 Michaël Fortin. All rights reserved.
//

#import "NSException+FilesAdditions.h"

@implementation NSException (FilesAdditions)

+ (instancetype)exceptionWithReason:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSString *reason = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	
	return [NSException exceptionWithName:@"APP_LEVEL_EXC" reason:reason userInfo:nil];
}

@end
