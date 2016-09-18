//
//  NSError+FilesAdditions.m
//  Obsidian
//
//  Created by Michaël Fortin on 2013-01-18.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import "NSError+FilesAdditions.h"
#import "NSException+FilesAdditions.h"

#define FilesErrorDomain @"FilesErrorDomain"

@implementation NSError (FilesAdditions)

+ (instancetype)errorWithDescription:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSError *error = [self errorWithCode:0 format:format arguments:args];
	va_end(args);
	
	return error;
}

+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSError *error = [self errorWithCode:code format:format arguments:args];
	va_end(args);
	
	return error;
}

+ (instancetype)errorWithCode:(NSInteger)code format:(NSString *)format arguments:(va_list)args
{
	if (!format) @throw [NSException exceptionWithReason:@"Nil format string when generating error!"];
	
	NSString *description = [[NSString alloc] initWithFormat:format arguments:args];
	NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : description };
	NSError *error = [NSError errorWithDomain:FilesErrorDomain code:code userInfo:userInfo];
	return error;
}

@end
